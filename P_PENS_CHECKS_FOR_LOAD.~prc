CREATE OR REPLACE PROCEDURE P_PENS_CHECKS_FOR_LOAD(
  MODE_          IN  INTEGER,         -- 0 - ВЫХОДИТЬ НА ПЕРВОЙ ЖЕ ОШИБКЕ, 1 - КОПИТЬ ВСЕ ОШИБКИ И ОТДАВАТЬ МАССИВОМ
  IDN_           IN  G_NAT_PERSON.IDN%TYPE,
  fm_            IN  g_nat_person.fm%type,
  nm_            IN  g_nat_person.nm%type,
  dt_            IN  g_nat_person.dt%type,
  SEX_           IN  G_NAT_PERSON.G_SEX%TYPE,
  paymentsType_  in  number := 1,  -- 15.12.2023 Бычков  Добавляем обработку заявлений по ОСНС
  includeOPV_    in  number := 1,  -- 15.12.2023 Бычков  Добавляем обработку заявлений по ОСНС
  g_person_      OUT g_nat_person.G_PERSON%type,
  ErrMsgArr      out main.k_types.TErrMsgArr,
  P_CONTRACT_    out k_types.TNumberArray,
  Err_Code       out Types.TErr_Code,
  Err_Msg        out Types.TErr_Msg)
is
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- ИСТОРИЯ ИЗМЕНЕНИЙ:
  -- ДАТА        КТО            COMMENTS  ГДЕ ИЗМЕНЯЛОСЬ
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- 05.05.2018: ТЕМЕКОВ АА ПИЛОТНАЯ ПРОЦЕДУРА ПРОВЕРОК ПРИ ЗАГРУЗКЕ PENS
  -- 19.09.2018 ТЕМЕКОВ АА ЗАДАЧА ХХХ, ЕСЛИ ПЕНС ВОЗРАСТ НЕ НАСТУПИЛ, И СТОИТ СООТВЕТСТВУЮЩАЯ НАСТРОЙКА, ТО ОШИБКА, ОТПРАВЛЯТЬ ОТРИЦАТЕЛЬНЫЙ ОТВЕТ PENSO
  -- 19.09.2018 ТЕМЕКОВ АА ЗАДАЧА 192926, НАДО УЧИТЫВАТЬ ВИСОКОСНЫЙ ГОД
  -- 24.10.2018 Темеков АА, задача 192926 - сделать ответ ЦОН Положительным, даже если на одном из ИПС есть действующее заявление, а на втором ИПС с ПН это заявление отсутствует.
  -- 07.11.2018 Темеков АА, задача 192926 - неправильно реализовал требование выше, исправил
  -- 01.04.2019 ТЕМЕКОВ АА, ЗАДАЧА 326287, ПОЛ ПРОВЕРЯТЬ ТОЖЕ
  -- 27.05.2019 ТЕМЕКОВ АА, ЗАДАЧА 326287, ПРОПИСАТЬ ПОЛ В ТЕКСТЕ ОШИБКИ ТОЖЕ
  -- 26-06-2019: МАМЕТОВ СЕРИК АЛИМАМЕТОВИЧ: ВНЕС ИЗМЕНЕНИЯ ПО ЗАДАЧЕ В БИТРИКСЕ №370168. ПО УСЛОВИЮ ЗАДАЧИ ПРИ ВЫЗОВЕ ЭТОЙ ПРОЦЕДУРЫ ИЗ РЕЖИМА ОБРАБОТКИ ЗАПРОСОВ ЦОН, ПРОВЕРКИ
  -- ДОЛЖНЫ РАБОТАТЬ ПО ПУНТКУ 2 И С 4 ПО 9 ПУНКТЫ ПОСТАНОВКИ. "В СЛУЧАЕ, ЕСЛИ ОТВЕТ В ЦОН ПОЛОЖИТЕЛЬНЫЙ, ТО ДЛЯ ДАННОГО СООБЩЕНИЯ ТАКЖЕ ОСУЩЕСТВЛЯЮТСЯ ВСЕ ПРОВЕРКИ, УКАЗАННЫЕ В
  -- РАЗДЕЛЕ "4 ОБРАБОТКА СВЕДЕНИЙ ПОСТУПЛЕНИИ ЗАЯВЛЕНИЙ НА ПОЛУЧЕНИЕ ПЕНСИОННЫХ ВЫПЛАТ ИЗ ЕНПФ ИЗ ГК" В ПУНКТАХ 2), С 4) ПО 9)."
  -- 15.12.2023 Бычков    Добавляем обработку заявлений по ОСНС
  -- 04.09.2025 Бычков    Необходимо принимать заявления по возрасту при наличии незакрытого заявления по ОСНС
  --                        в связи с изменениями в Правилах №521
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  fm_db_                g_nat_person.fm%type;
  nm_db_                g_nat_person.nm%type;
  dt_db_                g_nat_person.dt%type;
  SEX__                 g_nat_person.G_SEX%type;
  SEX_db_               g_nat_person.G_SEX%type;
  i                     integer := 0;
  j                     integer := 0;
  p_add_change_         p_add_change.P_ADD_CHANGE%type;
  p_g_contract_knd_     p_contract.p_g_contract_knd%type;
  p_g_contract_status_  p_contract.p_g_contract_status%type;
  cnt_                  integer := 0;
  p_contract_STR_       TYPES.TSTRINGARRAY;    --ДЛЯ ПРОЦЕДУРЫ G_UPDATE_NAT_PERSON
  IPS_SALDO_            P_Pack_State.TTwoSumRec;
  SALDO_                NUMBER := 0;
  IDOPERDAY_            NUMBER := 0;
  HAVE_CLAIM_PAY_       INTEGER := 0;
  HAVE_CLAIM_TRANS_     INTEGER := 0;
  STR_                  VARCHAR2(1024);   -- ДЛЯ РАЗНЫХ НУЖД
  IS_CALL_ZON_          NUMBER := 0;

  ProcName constant Types.tProc_Name := 'P_PENS_CHECKS_FOR_LOAD';
begin
  Err_Code := 0;
  Err_Msg  := '';

  SELECT DECODE(SEX_, 0, 3, 1, 2, 0)  --У нас в БД 2 мужчина 3 женщина
    INTO SEX__
    FROM DUAL;

  --=======================================================
  --Пункт 2. Если вкладчик не идентифицирован в БД ЕНПФ по ИИН
  --=======================================================
  begin
    select g.fm,
           g.nm,
           g.dt,
           G.G_SEX,
           g.G_PERSON
      into fm_db_,
           nm_db_,
           dt_db_,
           SEX_DB_,
           g_person_
      from g_nat_person g
     where g.IDN = IDN_;
  exception
    when no_data_found then
      ErrMsgArr(I).ErrCode := 3;
      ErrMsgArr(I).ErrMsgEnpf := 'Получатель не найден в АИС ЕНПФ';
      ErrMsgArr(I).ErrMsgGk := 'Получатель не найден в АИС ЕНПФ';

      if MODE_ = 0 then
        raise TYPES.E_ExecError;
      else
        i := i + 1;
      end if;
  end;
  --==========================================================

  -- 19.09.2018 ТЕМЕКОВ АА ЗАДАЧА ХХХ, ЕСЛИ ПЕНС ВОЗРАСТ НЕ НАСТУПИЛ, И СТОИТ СООТВЕТСТВУЮЩАЯ НАСТРОЙКА, ТО ОШИБКА,
  -- ОТПРАВЛЯТЬ ОТРИЦАТЕЛЬНЫЙ ОТВЕТ PENSO
  -- 19.09.2018 ТЕМЕКОВ АА ЗАДАЧА 192926, НАДО УЧИТЫВАТЬ ВИСОКОСНЫЙ ГОД
  DECLARE
    DATE_ DATE;
  BEGIN
    BEGIN
      DATE_ := TO_DATE(TO_CHAR(DT_DB_, 'DD.MM')||'.'||EXTRACT(YEAR FROM TRUNC(SYSDATE)), 'DD.MM.YYYY');
    EXCEPTION
      WHEN OTHERS THEN
        IF TO_CHAR(DT_DB_, 'DD.MM') = '29.02' THEN
          DATE_ := TO_DATE(TO_CHAR(DT_DB_ - 1, 'DD.MM')||'.'||EXTRACT(YEAR FROM TRUNC(SYSDATE)), 'DD.MM.YYYY');
        ELSE
          ErrMsgArr(I).ErrCode := 3;
          ErrMsgArr(I).ErrMsgEnpf := 'Исключительная ситуация - ошибка при конвертации даты. P_PENS_CHECKS_FOR_LOAD BLOCK 01';
          ErrMsgArr(I).ErrMsgGk := 'Исключительная ситуация - ошибка при конвертации даты. P_PENS_CHECKS_FOR_LOAD BLOCK 01';
          raise TYPES.E_ExecError;
        END IF;
    END;

    IF DATE_ > TRUNC(SYSDATE) AND PARAMS.GET_SYSTEM_SETUP_PARAM('RESPON_TO_REQUEST_BY_ZON_ENIS') = 1 AND MODE_ = 0
       and paymentsType_ = 1 -- 15.12.2023
    THEN
      ErrMsgArr(I).ErrCode := 3;
      ErrMsgArr(I).ErrMsgEnpf := 'У получателя отсутствует право на пенсионные выплаты из ЕНПФ на дату обращения в ГК';
      ErrMsgArr(I).ErrMsgGk := 'У получателя отсутствует право на пенсионные выплаты из ЕНПФ на дату обращения в ГК';
      raise TYPES.E_ExecError;
    END IF;
  END;

  --==============================================================================================================================================================================
  -- Пункт 3. если найден, но надо сравнить ФИО и ДР, поставил * т.к. тут одно из полей ФИО может быть только заполнено, и если
  -- 1) не совпадает, то найти загруженные и еще необработанные файлы формата J01 по ИИН (поле 16 - ИИН до внесения изменений)
  --    и вывести ошибку если найдено
  -- 01.04.2019 ТЕМЕКОВ АА, ЗАДАЧА 326287, ПОЛ ПРОВЕРЯТЬ ТОЖЕ
  --==============================================================================================================================================================================
  SELECT COUNT(1)
    INTO IS_CALL_ZON_
    FROM DUAL
   WHERE DBMS_UTILITY.FORMAT_CALL_STACK LIKE '%P_PARSE_INSERT_ZON%';

  --26-06-2019: МАМЕТОВ СЕРИК АЛИМАМЕТОВИЧ: ВНЕС ИЗМЕНЕНИЯ ПО ЗАДАЧЕ В БИТРИКСЕ №370168. ПО УСЛОВИЮ ЗАДАЧИ ПРИ ВЫЗОВЕ ЭТОЙ ПРОЦЕДУРЫ ИЗ РЕЖИМА ОБРАБОТКИ ЗАПРОСОВ ЦОН, ПРОВЕРКИ
  --ДОЛЖНЫ РАБОТАТЬ ПО ПУНТКУ 2 И С 4 ПО 9 ПУНКТЫ ПОСТАНОВКИ. "В СЛУЧАЕ, ЕСЛИ ОТВЕТ В ЦОН ПОЛОЖИТЕЛЬНЫЙ, ТО ДЛЯ ДАННОГО СООБЩЕНИЯ ТАКЖЕ ОСУЩЕСТВЛЯЮТСЯ ВСЕ ПРОВЕРКИ, УКАЗАННЫЕ В
  --РАЗДЕЛЕ "4 ОБРАБОТКА СВЕДЕНИЙ ПОСТУПЛЕНИИ ЗАЯВЛЕНИЙ НА ПОЛУЧЕНИЕ ПЕНСИОННЫХ ВЫПЛАТ ИЗ ЕНПФ ИЗ ГК" В ПУНКТАХ 2), С 4) ПО 9)."
  IF NVL(UPPER(FM_), '*') <> NVL(FM_DB_, '*') OR NVL(UPPER(NM_), '*') <> NVL(NM_DB_, '*') OR DT_ <> DT_DB_ OR SEX__ <> SEX_DB_ AND IS_CALL_ZON_ = 0 THEN
    select count(*)
      into cnt_
      from P_INGOING_PARSED_J01 j --(!) from P_INGOING_PARSED_J01$$O j
     where j.PROCEED_SIGN = 0
       and j.IDN = IDN_; --(!) and j.IDN$$ = ncrypto.encrypt(utl_raw.cast_to_raw(IDN_), 2, 1);

    if cnt_ > 0 then
      ErrMsgArr(I).ErrCode := 2;
      ErrMsgArr(I).ErrMsgEnpf := 'Имеется расхождение в реквизитах ФИ, дата рождения. В БД найден необработанный файл формата J01';
      i := i + 1;

    -- 2) если J01 не найден, то сверить с данными из ГБДФЛ
    else
      -- здесь будет процедура сверки данных с ГБДФЛ
      m__import_gbdfl.pl_checkfiodtogbdfl(IDN_,
                                          UPPER(fm_),    -- У Анвара проверяется большими буквами
                                          UPPER(nm_),
                                          '*',    --ft_,
                                          dt_,
                                          SEX__,
                                          err_code,
                                          err_msg,
                                          1 --Request_KDP_
                                          );
      if err_code = -2 then
        ErrMsgArr(I).ErrCode := 2;
        ErrMsgArr(I).ErrMsgEnpf := 'Не совпадают ФИ, дата рождения и (или) пол в запросе ГК, БД Фонда и ГБД ФЛ';
        i := i + 1;

      -- если сервис не доступен или вкладчик не найден --
      elsif err_code = -1 then
        ErrMsgArr(I).ErrCode := 2;
        ErrMsgArr(I).ErrMsgEnpf := 'Сервис ГБД ФЛ не доступен или получатель из запроса ГК по ИИН не найден в ГБД ФЛ. Детали '||err_msg;
        i := i + 1;

      -- если же вкладчик нашелся и ФИО ГК и ГБДФЛ совпадают, то вношу изменения к нам и сразу утверждаю запись
      elsif err_code = 0 then
        declare
          is_change_fm_ integer := 0;
          is_change_nm_ integer := 0;
          is_change_dt_ integer := 0;
          is_change_sex_ integer := 0;
        begin
          if nvl(upper(fm_), '*') <> nvl(fm_db_, '*') then
            is_change_fm_ := 1;
          end if;
          if nvl(upper(nm_), '*') <> nvl(nm_db_, '*') then
            is_change_nm_ := 1;
          end if;
          if dt_ <> dt_db_ then
            is_change_dt_ := 1;
          end if;
          if SEX__ <> SEX_DB_ then
            is_change_sex_ := 1;
          end if;

          g_update_nat_person(7001,   -- p_g_cng_natperson_reason_,
                              sysdate,    -- doc_date_,
                              null,       -- doc_num_
                              g_person_,  --g_person_,
                              p_contract_STR_,
                              upper(fm_),    -- fm_
                              upper(nm_),    -- nm_
                              null,    -- ft_
                              null,    -- fm_reg_
                              null,    -- nm_reg_
                              null,    -- ft_reg_
                              dt_,
                              SEX__,    -- sex_,
                              null,       -- is_republic_sitizen_
                              null,       -- sitizen_country_
                              null,       -- rnn_
                              null,       -- Opv_
                              null,       --idn_,
                              null,        --leaved_date_,
                              null,        --death_date_,
                              null,        --g_id_kind_,
                              null,        --id_serial_,
                              null,        --id_num_,
                              null,        --id_date_,
                              null,        --id_date_end_,
                              null,        --id_issuer_,
                              null,        --address_,
                              null,        --pind_,
                              null,        --adress_g_filial_,
                              null,        --adress_g_district_,
                              null,        --adress_g_city_,
                              null,        --adress_street_,
                              null,        --adress_house_num_,
                              null,        --adress_flat_num_,
                              null,        --adress_is_internat_,
                              null,        --phone_,
                              null,        --phone_work_,
                              null,        --phone_mobile_,
                              null,        --e_mail_,
                              null,        --email_is_blocked_,
                              null,        --p_g_access_balance_,
                              null,        --p_g_access_category_,
                              null,        --address_dop_,
                              null,        --adress_dop_g_filial_,
                              null,        --adress_dop_g_district_,
                              null,        --adress_dop_g_city_,
                              null,        --adress_dop_street_,
                              null,        --adress_dop_house_num_,
                              null,        --adress_dop_flat_num_,
                              null,        --adress_dop_post_index_,
                              is_change_fm_,           --is_change_fm_,
                              is_change_nm_,           --is_change_nm_,
                              0,            --is_change_ft_,
                              0,            --is_change_fm_reg_,
                              0,            --is_change_nm_reg_,
                              0,            --is_change_ft_reg_,
                              is_change_dt_,            --is_change_dt_,
                              0,           --is_change_rnn_,
                              0,            --is_change_idn_,
                              0,           --is_change_adress_dop_,
                              0,           --is_change_g_id_kind_,
                              0,           --is_change_adress_,
                              0,           --is_change_phone_,
                              0,           --is_change_phone_work_,
                              0,           --is_change_phone_mobile_,
                              0,           --is_change_e_mail_,
                              0,           --is_change_SIC_,
                              is_change_sex_,            --is_change_SEX_,
                              0,            --is_change_other_,
                              0,           -- is_change_opv_active_
                              0,           -- is_opv_active_
                              0,           -- IS_CHANGED_COUNTRY_
                              0,           -- do_audit
                              1,           -- do_commit_  -- потому что применение реквизитв не должно зависеть от проверок далее, может быть отрицательный ответ, но реквизиты должны быть применены
                              p_add_change_,
                              Err_Code,
                              Err_Msg);
          if Err_Code <> 0 then
            ErrMsgArr(I).ErrCode := 3;
            ErrMsgArr(I).ErrMsgEnpf := Err_Msg;
            raise TYPES.E_ExecError;
          end if;
        end;
      end if;
    end if;
  END IF;
  -- конец пункта 3
  --==========================================================

  --==========================================================
  -- Пункт 4. Проверка на наличие открытых ОПВ/ОППВ в любом статусе
  --==========================================================
  BEGIN
    SELECT W.WORKING_DATE
      INTO IDOPERDAY_
      FROM WORKING_DATE W
     WHERE W.IS_ACTIVE = 1;
  EXCEPTION
    WHEN OTHERS THEN
      SELECT MAX(W.WORKING_DATE)
        INTO IDOPERDAY_
        FROM WORKING_DATE W;
  END;

  p_g_contract_status_ := 5;   -- мне нужен статус 5
  for rec in (select *
                from p_contract pc
               where pc.g_person_recipient = g_person_
                 and pc.p_g_contract_knd in (decode(includeOPV_, 1,1, 18), decode(includeOPV_, 1,10, 18), 11, 18) -- если includeOPV_!=1, то не нужно искать ОПВ
                 and pc.date_close is null)
  loop
    p_g_contract_knd_ := rec.p_g_contract_knd;
    if Rec.p_g_Contract_Status <> 5 then
      p_g_contract_status_ := Rec.p_g_Contract_Status;
    end if;

    -- 01.11.2018 ТЕМЕКОВ АА, ЗАДАЧА 192926, ЗАЯВКА 19496, НА ДОГОВОРЕ С НУЛЕВЫМ ИПС, НЕ ЗАВОДИМ ЗАЯВЛЕНИЕ
    -- поэтому сюда перенес вычисления суммы. тут же для пункта 6 проведу вычисления суммы ИПС, если сумма больше нуля, то пихаю договор в массив, иначе нет
    ips_saldo_ := p_get_ips_and_cu_saldo(rec.p_contract, 1, idoperday_);

    if ips_saldo_.sum1 = 0 then
      select 'Имеется нулевой остаток на ИПС за счет '||g.short_name
        into str_
        from p_contract c,
             p_g_contract_knd g
       where c.p_g_contract_knd = g.p_g_contract_type
         and c.p_contract = rec.p_contract;

      errmsgarr(i).errcode := 2;
      errmsgarr(i).errmsgenpf := str_;
      errmsgarr(i).errmsggk := str_;
      i := i + 1;
    else
      p_contract_(j) := rec.p_contract;
      j := j + 1;
      saldo_ := saldo_ + ips_saldo_.sum1;
    end if;
  end loop;

  -- если найден единственный отрытый договор вида ТД
  if J = 1 and p_g_contract_knd_ = 1 then
    ErrMsgArr(I).ErrCode := 2;
    ErrMsgArr(I).ErrMsgEnpf := 'Найден единственный отрытый договор вида ТД.';
    i := i + 1;

  -- если хоть у одного из найденных открытых договоров вида ОПВ/ТД и/или ОППВ статус иной чем 5 "Обработан успешно"
  elsif J > 0 and p_g_contract_status_ <> 5 then
    ErrMsgArr(I).ErrCode := 2;
    ErrMsgArr(I).ErrMsgEnpf := 'У найденного (-ых) договора (-ов) неуспешный статус обработки договора.';
    i := i + 1;

  elsif J = 0 then
    ErrMsgArr(I).ErrCode := 3;
    ErrMsgArr(I).ErrMsgEnpf := 'Отсутствует открытый ИПС вида ОПВ и/или ОППВ.';
    ErrMsgArr(I).ErrMsgGk := 'У получателя отсутствуют пенсионные накопления.';
    if mode_ = 0 then
      raise TYPES.E_ExecError;
    else
      i := i + 1;
    end if;
  end if;
  -- Конец пункт 4
  --==========================================================

  --==========================================================
  -- Пункт 5. проверить наличие открытого счета кредиторской задолженности (КЗ)
  --==========================================================
  SELECT COUNT(*)
    INTO CNT_
    FROM P_CONTRACT PC
   WHERE PC.G_PERSON_RECIPIENT = G_PERSON_
     AND PC.P_G_CONTRACT_KND = 13
     AND PC.DATE_CLOSE IS NULL;

  IF CNT_ > 0 AND P_CONTRACT_.COUNT > 0 THEN
    ErrMsgArr(I).ErrCode := 2;
    ErrMsgArr(I).ErrMsgEnpf := 'Имеется КЗ.';
    i := i + 1;
  END IF;
  -- Конец пункт 5
  --==========================================================

  --==========================================================
  -- Пункт 6. Осуществить проверку на предмет наличия остатка на ИПС вида ОПВ/ТД и/или ОППВ
  -- 01.11.2018 ТЕМЕКОВ АА, ЗАДАЧА 192926, ЗАЯВКА 19496, НА ДОГОВОРЕ С НУЛЕВЫМ ИПС, НЕ ЗАВОДИМ ЗАЯВЛЕНИЕ
  -- все что тут было перенес выше в пункт 4
  -- по идее это можно было перетащить выше, но по ТЗ почему-то так шло, не стал перемешивать
  --==========================================================
  /*FOR J IN 0..P_CONTRACT_.COUNT - 1
  LOOP
    BEGIN
      SELECT W.WORKING_DATE
        INTO IDOPERDAY_
        FROM WORKING_DATE W
       WHERE W.IS_ACTIVE = 1;
    EXCEPTION
      WHEN OTHERS THEN
        SELECT MAX(W.WORKING_DATE)
          INTO IDOPERDAY_
          FROM WORKING_DATE W;
    END;

    IPS_SALDO_ := P_GET_IPS_AND_CU_SALDO(P_CONTRACT_(j), 1, IDOPERDAY_);
    SALDO_ := SALDO_ + IPS_SALDO_.SUM1;
  END LOOP;*/

  IF SALDO_ = 0 THEN
    ErrMsgArr(I).ErrCode := 3;
    ErrMsgArr(I).ErrMsgEnpf := 'Совокупный остаток по всем открытым ИПС вкладчика (получателя) равен 0.';
    ErrMsgArr(I).ErrMsgGk := 'У получателя отсутствуют пенсионные накопления.';
    if mode_ = 0 then
      raise TYPES.E_ExecError;
    else
      i := i + 1;
    end if;
  /*
  ЭТО УЖЕ СДЕЛАЛ В ПУНКТЕ 4
  ELSIF SALDO_ > 0 AND STR_ IS NOT NULL THEN
    ErrMsgArr(I).ErrCode := 2;
    ErrMsgArr(I).ErrMsgEnpf := STR_;
    ErrMsgArr(I).ErrMsgGk := STR_;
    i := i + 1;*/
  END IF;
  -- Конец пункт 6
  --==========================================================

  --==========================================================
  -- Пункт 7. проверку на предмет наличия открытого заявления на выплату/перевод
  -- 24.10.2018 Темеков АА, задача 192926 - сделать ответ ЦОН Положительным, даже если на одном из ИПС есть действующее заявление,
  -- а на втором ИПС с ПН это заявление отсутствует.
  -- 07.11.2018 Темеков АА, задача 192926 - неправильно реализовал требование выше, исправил
  --==========================================================
  HAVE_CLAIM_PAY_ := 0;
  FOR J IN 0..P_CONTRACT_.COUNT - 1
  LOOP
    select count(*)
      into CNT_
      from p_claim_pay_out p join p_g_pay_out_sub_type st on st.p_g_pay_out_sub_type = p.P_G_PAY_OUT_SUB_TYPE
     where p.P_CONTRACT = P_CONTRACT_(J)
       and st.p_g_pay_out_type in (2,8)
       and p.DATE_CLOSE is null
       and p.IS_ACTIVE = 1
       and p.P_G_CLAIM_STATUS = 8
       and p.P_G_CLAIM_PAY_OUT_KND = 4
       -- 04.09.2025 Бычков  Теперь будем принимать заявления по возрасту при наличии незакрытого заявления по ОСНС в связи с изменениями в Правилах №521
       and (paymentsType_ != 1 or p.p_g_pay_out_sub_type not in (600,601,602,603));

    HAVE_CLAIM_PAY_ := HAVE_CLAIM_PAY_ + CNT_;

    select count(*)
      into HAVE_CLAIM_TRANS_
      from p_Claim_Transfer p
     where p.P_CONTRACT = P_CONTRACT_(J)
       and p.P_G_CLAIM_STATUS NOT IN (-2, -3, -7, 8);
  END LOOP;

  IF HAVE_CLAIM_PAY_ = P_CONTRACT_.COUNT THEN
    ErrMsgArr(I).ErrCode := 3;
    ErrMsgArr(I).ErrMsgEnpf := 'Имеется действующее заявление на выплату по возрасту и (или) инвалидности.';
    ErrMsgArr(I).ErrMsgGk := 'Имеется действующее заявление на выплату по возрасту и (или) инвалидности.';
    if mode_ = 0 then
      raise TYPES.E_ExecError;
    else
      i := i + 1;
    end if;
  END IF;

  IF HAVE_CLAIM_TRANS_ > 0 THEN
    ErrMsgArr(I).ErrCode := 3;
    ErrMsgArr(I).ErrMsgEnpf := 'Имеется на исполнении заявление на перевод.';
    ErrMsgArr(I).ErrMsgGk := 'Имеется на исполнении заявление на перевод.';
    if mode_ = 0 then
      raise TYPES.E_ExecError;
    else
      i := i + 1;
    end if;
  END IF;
  -- Конец пункт 7
  --==========================================================

  --==========================================================
  -- Пункт 8. проверку на предмет наличия блокировки ИПС
  --==========================================================
  FOR J IN 0..P_CONTRACT_.COUNT - 1
  LOOP
    IF p_get_is_debetcredit_account(P_CONTRACT_(j), 1) = 1 THEN
      ErrMsgArr(I).ErrCode := 2;
      ErrMsgArr(I).ErrMsgEnpf := 'На одном или обоих ИПС имеется блокировка по дебету.';
      i := i + 1;
      exit;
    END IF;
  END LOOP;
  -- Конец пункт 8
  --==========================================================

  --==========================================================
  -- Пункт 9. проверку на предмет отсутствия в БД Фонда и (или) исторической
  -- БД исполненного заявления на выплату на погребение и (или) наследникам
  --==========================================================
  FOR J IN 0..P_CONTRACT_.COUNT - 1
  LOOP
    CNT_ := P_GET_CLAIMS_POGREB_NASL(G_PERSON_,
                                     1, --MODE_ ПРОВЕРКА ПОГРЕБЕНИЯ/НАСЛЕДСТВА
                                     ERR_CODE,
                                     ERR_MSG);

    if ERR_CODE <> 0 then
      ErrMsgArr(I).ErrCode := 3;
      ErrMsgArr(I).ErrMsgEnpf := ERR_MSG;
      raise types.E_ExecError;
    end if;

    if cnt_ > 0 then
      ErrMsgArr(I).ErrCode := 2;
      ErrMsgArr(I).ErrMsgEnpf := 'В БД Фонда и (или) исторической БД имеется исполненное заявления на выплату или операция на погребение и (или) наследникам.';
    end if;
  END LOOP;
  -- Конец пункт 8
  --==========================================================

EXCEPTION
  WHEN TYPES.E_ExecError THEN
    ROLLBACK;
  WHEN OTHERS THEN
    Err_Code := SQLCODE;
    Err_Msg  := ProcName || ' ' ||
                ADM.ERROR_PACK.GET_ERR_MSG('0000', SQLCODE, SQLERRM);

END P_PENS_CHECKS_FOR_LOAD;
/
