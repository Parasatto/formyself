CREATE OR REPLACE PROCEDURE p_build_outgoing_mt103(
   P_CLAIM_PAY_OUT_  IN  TYPES.TSTRINGARRAY,
   DATE_             IN  DATE,         --- Дата отправки в банк-клиент
   CUR_DATE_         IN  DATE,         --- Дата валютирования
   DOC_DATE_         IN  DATE,         --- Дата конвертации
   G_JUR_PERSON_EAES_ IN TYPES.TSTRINGARRAY,--G_JUR_PERSON_EAES.G_JUR_PERSON_EAES%TYPE DEFAULT 0,
   CBODY_            OUT CLOB,
   ERR_CODE          OUT ADM.TYPES.TERR_CODE,
   ERR_MSG           OUT ADM.TYPES.TERR_MSG
  )
IS

  ----------------------------------------------------------------------------------------------
  -- Процедура для формирования заявок по выплатам в инвалюте и выгрузки файла формата МТ103 --
  -- АВТОРЫ: ТЕМЕКОВ АЙДЫН, МАМЕТОВ СЕРИК НОЯБРЬ 2018 ГОДА --
  ----------------------------------------------------------------------------------------------
  -- История изменений:
  -- Дата        Кто             Обьект                     Comments  где изменялось
  ----------------------------------------------------------------------------------------------
  -- 28-11-2018: ТЕМЕКОВ АЙДЫН   День рождение процедуры. Сделано формирование файла и выгрузка ее в переменную CBODY_
  -- 01-12-2018: МАМЕТОВ СЕРИК   Заполнение таблицы O_MT103
  -- 21-12-2018: МАМЕТОВ СЕРИК   Изменил логику формирования CBODY_. Теперь будет один файл CBODY_ по переданному массиву P_CLAIM_PAY_OUT_
  -- 25-09-2019: МАМЕТОВ СЕРИК   ПО ЗАДАЧЕ В БИТРИКСЕ №416521 БЫЛИ ДОБАВЛЕНЫ НОВЫЕ ВХОДЯЩИЕ ПЕРЕМЕННЫЕ, ДАТА ВАЛЮТИРОВАНИЯ, ДАТА ДОКУМЕНТА:
  --                             ПРИ ФОРМИРОВАНИИ ПЛАТЕЖНОГО СООБЩЕНИЯ В ФОРМАТЕ МТ-103 УСТАНОВИТЬ: - ВОЗМОЖНОСТЬ ВЫБОРА ДАТЫ ВАЛЮТИРОВАНИЯ И ДАТЫ ДОКУМЕНТА ВРУЧНУЮ, ПРИ ЭТОМ В СЛУЧАЕ ОТСУТСТВИЯ ЗАВЕДЕННОЙ
  --                             ВРУЧНУЮ ДАТЫ ВАЛЮТИРОВАНИЯ, СЧИТАТЬ ЕЕ РАВНОЙ ДАТЕ ДОКУМЕНТА; - СУММУ В ВАЛЮТЕ РАССЧИТЫВАТЬ В СООТВЕТСТВИИ С КУРСОМ ВАЛЮТЫ НА УСТАНОВЛЕННУЮ ВРУЧНУЮ ДАТУ ДОКУМЕНТА.
  -- 16-10-2019: МАМЕТОВ СЕРИК   ПО ЗАДАЧЕ В БИТРИКСЕ №421406 ИЗМЕНИЛ, ЧТО БЫ ОТЧЕСТВО НЕ ВЫХОДИЛО ПРИ ОТМЕТКЕ В ЗАЯВЛЕНИИ "БЕЗ ОТЧЕСТВА"
  --                             "В МОДУЛЕ "КЛИЕНТЫ" ПРОСТАВЛЕНА ГАЛОЧКА, СООТВЕТСТВЕННО В МТ103 ДОЛЖЕН БЫТЬ БЕЗ ОТЧЕСТВА. УСТАНОВИ, ПОЖАЛУЙСТА, ПРОВЕРКУ НА ЭТИ ДВЕ ГАЛОЧКИ. ПРОВЕРКА ПУСТЬ БУДЕТ ПО ВСЕМ ВАЛЮТАМ."
  -- 25-10-2019: МАМЕТОВ СЕРИК   Необходимо при формировании назначении платежа и наименования бенефициара учитывать через кого подано заявление
  -- 31-10-2019: МАМЕТОВ СЕРИК   Позвонил куаныш из НБ и сказал, что наименование отправителя, страна, адрес отправлялись в верхнем регистре. также приписка к стране "РЕСПУБЛИКА"
  -- 30-11-2019: МАМЕТОВ СЕРИК   По просьбе АНЕЛЬ и САУЛЕ ДУиОПА добавил возможность выводить счет и БИК банка с апострофами (MAIN.P_GET_STR_WITH_APOSTROPHE) если только БИК выплаты в БЕЛОРУСИЮ в РОССИЙСКИХ РУБЛЯХ
  -- 20-02-2020: МАМЕТОВ СЕРИК   Добавил возможность сохранения истории по каждому заявлению на перевод в ин.валюте
  -- 07-03-2020: МАМЕТОВ СЕРИК   ПО ЗАДАЧА № 491884 ВНЕС ИЗМЕНЕНИЯ "ПРОШУ ВАС ДОРАБОТАТЬ В МТ-103 ДАТУ "ЗАЯВЛЕНИЕ НА ПЕРЕВОД" ПЕРВЫЕ 4 СИМВОЛА В ПОЛЕ :20:0503001, ДОЛЖЕН БРАТЬСЯ ПО ЗАДАННОМУ ДНЮ В ИАИС-2/ВЫПЛАТЫ/ПЕЧАТЬ ПЛАТЕЖЕЙ С ВИДОМ ВЫПЛАТЫ "ВЫПЛАТЫ В ЗАГРАНИЦУ"/ УКАЗАТЬ ДАТУ ДОКУМЕНТА ВРУЧНУЮ."
  -- 07-03-2020: МАМЕТОВ СЕРИК   Добавил новое поле F72 информация отправителя получателю
  -- 11.04.2022: Миреев А.       добавил distinct чтоб убрать дубли
  -- 19.08.2022: Миреев А        Заявка №323. 'Выплаты в компетентные органы (КО) стран ЕАЭС в иностранной валюте. Реализовать: отдельное КНП в распоряжении на конвертацию (МТ100) и на
  --                             перевод денег (МТ103), корректное назначение, корректные реквизиты
  --                             5. Платежное поручение по пенсионным выплатам в иностранной валюте в страны ЕАЭС формируется в формате МТ103 ИАИС-2/Операции/ Выплаты/
  --                             Печать платежей с видом выплаты «выплата за границу»/ с КНП 105 с указанием банковских реквизитов компетентного органа, осуществляющего доставку пенсии.
  --                             При этом назначение платежа в платежке должно сформироваться следующим текстом: «ВЫПЛАТА ПЕНСИИ ПО СОГЛАШЕНИЮ (ЕАЭС) (за I/II/III/IV* квартал 2022г.)»
  -- 04.05.2023: Миреев А.       добавил заполнение CURRENCY_COURSE и KZT_SUM в таблице o_mt103
  -- 03.07.2023  AnvarT          Перевел назначение по беларусии на английский яз
  -- 27.03.2024  AnvarT          Нумерацию беру без добавочного кода, т.к. нумерация уже будет нормализована
  -- 24.04.2024  AnvarT          Корректируем суммы в иностранной валюте по ошибке округления в таблице O_MT103
  -- 16.05.2024  AnvarT          Подравнял расчет корректировки
  -- 07.02.2025 OlzhasT          Доработки согласно задаче №1170835
  -- 01.04.2025  AnvarT          Корректировка округления
  -- 03.04.2025  AnvarT          Чуть добавил протоколов
  -- 04.04.2025  AnvarT          Изменил сортировку выборки для формирования
  -- 15.04.2025  AnvarT          Поправил выборку
  -- 16.04.2025  AnvarT          Поправил выборку
  -- 18.04.2025  AnvarT          vldSEND_DATE Дата отправки в банк-клиент,  :32A: - vldFCurr_Date
  -- 08.07.2025  AnvarT          Поправил выборку для реконвертации
  -- 14.08.2025  AnvarT          Поправил выборку для реконвертации по дате vldFCurr_Date
  -- 14.11.2025  AnvarT          Добавил в формирование МТ значение f57c_benef_address, f59_benef_address
  -- 14.11.2025  AnvarT          Добавил в формирование /Adrline/' o.f57c_benef_address
  -- 14.11.2025  AnvarT          Добавил в формирование МТ значение f57c_benef_address, f59_benef_address
  -- 26.11.2025  AnvarT          Добавлены услования  если RUB то Adrline не нужно, для других проверим если нет свифт кода то добавляем f57c_benef_address
  -- 21.01.2026  AnvarT          Назначение платежа меняетя в в зависимости от типа заявления и валюты PENSION PAYMENT IN CONNECTION WITH THE DEPARTURE FOR PERMANENT
  ----------------------------------------------------------------------------------------------
  PROCNAME             CONSTANT  TYPES.TPROC_NAME := 'P_BUILD_OUTGOING_MT103';
  CrLf                 constant varchar2(2) := chr(13)|| chr(10);
  SENDER_              MAIN.OUTGOING_MT.SENDER % TYPE;
  SENDER_NAME_         MAIN.OUTGOING_MT.SENDER_NAME % TYPE;
  RECEIVER_            MAIN.OUTGOING_MT.RECEIVER % TYPE;
  MAIN_HEADER_         MAIN.OUTGOING_MT.MAIN_HEADER % TYPE;
  APP_HEADER_          MAIN.OUTGOING_MT.APP_HEADER % TYPE;
  ERR_CODE_            ADM.TYPES.TERR_CODE;
  ERR_MSG_             ADM.TYPES.TERR_MSG;
  BODY_                CLOB;
  P_CLAIM_PAY_OUT_ARR  TYPES.TINTARRAY;
  G_JUR_PERSON_EAES_ARR  TYPES.TINTARRAY;
  CNT_                 INTEGER;
  vliCNT                 INTEGER;
  WORKING_DATE_        WORKING_DATE.WORKING_DATE%TYPE;
  vldSEND_DATE         DATE;                               --- Дата отправки в банк-клиент
  NUM_PP_              NUMBER;
  FCUR_DATE_           DATE;
  vldFDoc_DATE         DATE;
  vldFCurr_Date        DATE;
  F70_PAY_ASSIGN_      MAIN.O_MT103.F70_PAY_ASSIGN%TYPE;
  F59_BENEF_NAME_      MAIN.O_MT103.F59_BENEF_NAME%TYPE;
  FM_                  MAIN.G_NAT_PERSON.FM%TYPE;
  NM_                  MAIN.G_NAT_PERSON.NM%TYPE;
  FT_                  MAIN.G_NAT_PERSON.FT%TYPE;
  O_MT103_             NUMBER;
  vliDelta             NUMBER;
  F72_                 VARCHAR2(1024);
  vlsNum               VARCHAR2(100);
  -- 19.08.2022: Миреев А Заявка №323. 'Выплаты в компетентные органы (КО) стран ЕАЭС в иностранной валюте
  -- Константы
  RUSSIA CONSTANT NUMBER     := 2;
  BELARUSSIA CONSTANT NUMBER := 34;
  KYRGYZSTAN CONSTANT NUMBER := 108;
  vlcTmp                              clob;
  vlcLogs                             clob;
  vlcLogStep                          clob;

  procedure pl_O_MT103_del(vliP_CLAIM_PAY_OUT IN  number) is --- Надо удалить старые O_MT103 которые возможно были ранее сформированы
    vliMT103 number;
  begin
    select sum(o_mt103)
    into vliMT103
    from (select 0 o_mt103 from dual
          union all
          select o_mt103
          from main.d__lt_mt103
          where o_mt103 in (select O_MT103
                            from main.O_MT103
                            where P_CLAIM_PAY_OUT=vliP_CLAIM_PAY_OUT)
            and o_mt in (select o_mt from main.o_mt where state in (0,1)));     --- Только те кто только что сформированы, иначе грохмем какие нибуть старые заявления
    if vliMT103<>0 then
      delete main.O_MT103 where o_mt103=vliMT103;
      delete main.d__lt_mt103 where o_mt103=vliMT103;
    end if;
  end;


begin
  ERR_CODE  := 0;
  ERR_MSG   := ' ';
  NUM_PP_   := 0;

  vlcTmp := vlcTmp||' P_CLAIM_PAY_OUT_[';
  for I IN P_CLAIM_PAY_OUT_.FIRST..P_CLAIM_PAY_OUT_.LAST loop       -- Преобразуем массив строк в массив целых чисел
    vlcTmp := vlcTmp||P_CLAIM_PAY_OUT_(I)||';';
  end loop;
  vlcTmp := vlcTmp||']';

  vlcTmp := vlcTmp||' G_JUR_PERSON_EAES_[';
  for I IN G_JUR_PERSON_EAES_.FIRST..G_JUR_PERSON_EAES_.LAST loop   -- Преобразуем массив строк в массив целых чисел
    vlcTmp := vlcTmp||G_JUR_PERSON_EAES_(I)||';';
  end loop;
  vlcTmp := vlcTmp||']';

  vlcLogs     := vlcLogs||chr(10)||(to_char(systimestamp,'hh24:mi:ss.FF')||' Start'
                        ||chr(10)||' DATE_['||DATE_||']'
                        ||chr(10)||' CUR_DATE_['||CUR_DATE_||']'
                        ||chr(10)||' DOC_DATE_['||DOC_DATE_||']'
                        ||chr(10)||vlcTmp
                        );


  if CONNECTION_PARAM.IDUSER IS null then
    CONNECTION_PARAM.SET_PARAMS(ERR_CODE_, ERR_MSG_);
  end if;

  begin
    select W.WORKING_DATE, W.WORK_DATE
    into CONNECTION_PARAM.IDOPERDAY, CONNECTION_PARAM.DOPER
    from WORKING_DATE W
    where W.IS_ACTIVE = 1;
  exception
    when others then
      NULL;
  end;

  vlcLogs     := vlcLogs||chr(10)||(to_char(systimestamp,'hh24:mi:ss.FF')||' Start'
                        ||chr(10)||' CONNECTION_PARAM.IDOPERDAY['||CONNECTION_PARAM.IDOPERDAY||']'
                        ||chr(10)||' CONNECTION_PARAM.DOPER['||CONNECTION_PARAM.DOPER||']'
                        );

  WORKING_DATE_ := MAIN.WORKING_DATE_PACK.GET_WORKING_DATE_BY_WORK_DATE(DATE_);


  for I IN P_CLAIM_PAY_OUT_.FIRST..P_CLAIM_PAY_OUT_.LAST loop       -- Преобразуем массив строк в массив целых чисел
    --05.09.2022: Миреев А.
    --if P_CLAIM_PAY_OUT_(I) = '0' then
    --  CONTINUE;
    --end if;
    P_CLAIM_PAY_OUT_ARR(I) := TO_NUMBER(P_CLAIM_PAY_OUT_(I));
  end loop;

  for I IN G_JUR_PERSON_EAES_.FIRST..G_JUR_PERSON_EAES_.LAST loop   -- Преобразуем массив строк в массив целых чисел
    --05.09.2022: Миреев А.
    --if G_JUR_PERSON_EAES_(I) = '0' then
    --  CONTINUE;
    --end if;
    G_JUR_PERSON_EAES_ARR(I) := TO_NUMBER(G_JUR_PERSON_EAES_(I));
  end loop;


  ADM.UTILS_PACK.FILL_TEM_INT_TABLE(P_CLAIM_PAY_OUT_ARR);       -- Очищаю и затем заполняю значениями из массива ID_OPR_ARR таблицу T_INT_TABLE#

  ADM.UTILS_PACK.FILL_TEM_INT_TABLE1(G_JUR_PERSON_EAES_ARR);    -- Очищаю и затем заполняю значениями из массива ID_OPR_ARR таблицу T_INT_TABLE#


  select decode(To_Char(CUR_DATE_, 'DD.MM.YYYY'), '00.00.0000', NULL, TRUNC(CUR_DATE_))
       , CUR_DATE_
       , DOC_DATE_
       , DATE_
  into FCUR_DATE_, vldFCurr_Date, vldFDoc_DATE, vldSEND_DATE
  from DUAL;

  vlcLogs     := vlcLogs||chr(10)||(to_char(systimestamp,'hh24:mi:ss.FF')||' Start'
                        ||chr(10)||' FCUR_DATE_['||FCUR_DATE_||']'
                        ||chr(10)||' vldFCurr_Date['||vldFCurr_Date||']'
                        ||chr(10)||' vldFDoc_DATE['||vldFDoc_DATE||']'
                        );



  ----------------------------------------------------------- ЗАПОЛНЯЕМ ДАННЫМИ ТАБЛИЦУ O_MT103 -------------------------------------------------------------------------------------

  for vlrCur IN (select ID from ADM.T_INT_TABLE#                 --- Надо удалить старые O_MT103 которые возможно были ранее сформированы
                 ) loop
    pl_O_MT103_del(vlrCur.ID);
  end loop;

  -- 01-10-2019: МАМЕТОВ СЕРИК АЛИМАМЕТОВИЧ: ПО ЗАДАЧЕ В БИТРИКСЕ №416892 НОМЕР ЗАЯВЛЕНИЯ НА ПЕРЕВОД ДОЛЖЕН БЫТЬ СКВОЗНОЙ ПО ВСЕМ ВИДАМ ВАЛЮТ В ТЕЧЕНИИИ ДНЯ И КАЖДЫЙ ОПЕРАЦИОННЫЙ ДЕНЬ ДОЛЖЕН НАЧИНАТЬСЯ 1.
  -- НОМЕР ЗАЯВЛЕНИЯ НА ПЕРЕВОД НЕ ДОЛЖЕН УВИЛИЧИВАТЬСЯ ОТ КОЛИЧЕСТВА ПЕЧАТИ ТОГО ЖЕ ЭКЗМПЛЯРА ЗАЯВЛЕНИЯ
  --select COUNT(1)
  --into CNT_
  --from MAIN.P_PAYMENT_INFO PI
  --where PI.WORKING_DATE = WORKING_DATE_
  --  and PI.NUM_CLAIM_PAY_OUT_TRANSFER IS NOT NULL;

  --if CNT_ = 0 then
  for CUR IN (select NUM, CODE
                from (select 1 AS NUM, G.CODE
                      from MAIN.G_CURRENCY G
                      where G.CODE = 'RUB'
                      union
                      select 2 AS NUM, G.CODE
                      from MAIN.G_CURRENCY G
                      where G.CODE = 'USD'
                      union
                      select 3 AS NUM, G.CODE
                      from MAIN.G_CURRENCY G
                      where G.CODE = 'EUR'
                      union
                      select 4 AS NUM, G.CODE
                      from MAIN.G_CURRENCY G
                      where G.CODE = 'GBP'
                      --05.09.2022: Миреев А. Добавил Беларусь, Киргизию и Армению
                      union
                      select 5 AS NUM, G.CODE
                      from MAIN.G_CURRENCY G
                      where G.CODE = 'BYN'
                      union
                      select 6 AS NUM, G.CODE
                      from MAIN.G_CURRENCY G
                      where G.CODE = 'KGS'
                      union
                      select 7 AS NUM, G.CODE
                      from MAIN.G_CURRENCY G
                      where G.CODE = 'AMD')
                      order by NUM
             ) loop
    vlcLogs     := vlcLogs||' CODE['||CUR.CODE||']';

    for REC IN (select PI.P_PAYMENT_INFO
                from MAIN.P_OPR PO
                   , MAIN.WORKING_DATE WD
                   , MAIN.P_G_OPRKND K
                   , MAIN.P_LT_OPR_CLAIM LT
                   , MAIN.P_CLAIM_PAY_OUT CP
                   , MAIN.P_PAYMENT_INFO PI
                   , MAIN.G_CURRENCY C
                where PO.WORKING_DATE = WD.WORKING_DATE
                  and WD.WORK_DATE = vldSEND_DATE
                  and PI.WORKING_DATE = WORKING_DATE_
                  and PO.P_G_OPRKND = K.P_G_OPRKND
                  and K.P_G_GROUP_OPRKND IN (9, 119, 138)
                  and PO.P_OPR = LT.P_OPR
                  and LT.P_CLAIM_PAY_OUT = CP.P_CLAIM_PAY_OUT
                  and CP.BANK_IS_FOREIGN = 1
                  and CP.P_CLAIM_PAY_OUT = PI.P_CLAIM_PAY_OUT
                  and CP.G_CURRENCY = C.G_CURRENCY
                  and C.CODE = CUR.CODE
                order by decode('USD',cp.FM_Lat||' '||cp.NM_Lat
                               ,'EUR',cp.FM_Lat||' '||cp.NM_Lat
                               ,'GBP',cp.FM_Lat||' '||cp.NM_Lat
                               ,cp.FM||' '||cp.NM||' '||cp.FT), cp.DT, cp.P_CLAIM_PAY_OUT
               ) loop
      NUM_PP_ := NUM_PP_ + 1;

      vlsNum  := To_Char(vldFDoc_DATE,'ddmm')||lpad(NUM_PP_, 3,'0');

      update MAIN.P_PAYMENT_INFO PI
         SET PI.NUM_CLAIM_PAY_OUT_TRANSFER = vlsNum
      where PI.P_PAYMENT_INFO = REC.P_PAYMENT_INFO;
      commit;
    end loop;
  end loop;
  --end if;

  -- 07-03-2020: МАМЕТОВ СЕРИК АЛИМАМЕТОВИЧ: ПО ЗАДАЧА № 491884 ВНЕС ИЗМЕНЕНИЯ "ПРОШУ ВАС ДОРАБОТАТЬ В МТ-103 ДАТУ "ЗАЯВЛЕНИЕ НА ПЕРЕВОД" ПЕРВЫЕ 4 СИМВОЛА В ПОЛЕ :20:0503001,
  -- ДОЛЖЕН БРАТЬСЯ ПО ЗАДАННОМУ ДНЮ В ИАИС-2/ВЫПЛАТЫ/ПЕЧАТЬ ПЛАТЕЖЕЙ С ВИДОМ ВЫПЛАТЫ "ВЫПЛАТЫ В ЗАГРАНИЦУ"/ УКАЗАТЬ ДАТУ ДОКУМЕНТА ВРУЧНУЮ."

  vlcTmp := '[';

  for REC IN (select *
              from (select -- NVL(lpad(PI.NUM_CLAIM_PAY_OUT_TRANSFER, 7,'0'), CP.CLAIM_NUM) AS F20, -- 27.03.2024  AnvarT        Нумерацию беру без добавочного кода, т.к. нумерация уже будет нормализована
                           To_Char(vldSEND_DATE, 'DDMM')
                         ||LPAD(To_Char(ROW_NUMBER () OVER (order by decode(C.CODE,'RUB','1','USD','2','EUR','3','GBP','4',nvl(C.CODE,'9')), CP.fm, CP.nm)), 3, '0') AS F20, -- 27.03.2025  AnvarT
                     C.CODE,
                     -- 25-09-2019: МАМЕТОВ СЕРИК АЛИМАМЕТОВИЧ: ПО ЗАДАЧЕ В БИТРИКСЕ №416521 БЫЛИ ДОБАВЛЕНЫ НОВЫЕ ВХОДЯЩИЕ ПЕРЕМЕННЫЕ, ДАТА ВАЛЮТИРОВАНИЯ, ДАТА ДОКУМЕНТА:
                     -- ПРИ ФОРМИРОВАНИИ ПЛАТЕЖНОГО СООБЩЕНИЯ В ФОРМАТЕ МТ-103 УСТАНОВИТЬ: - ВОЗМОЖНОСТЬ ВЫБОРА ДАТЫ ВАЛЮТИРОВАНИЯ И ДАТЫ ДОКУМЕНТА ВРУЧНУЮ, ПРИ ЭТОМ В СЛУЧАЕ ОТСУТСТВИЯ ЗАВЕДЕННОЙ
                     -- ВРУЧНУЮ ДАТЫ ВАЛЮТИРОВАНИЯ, СЧИТАТЬ ЕЕ РАВНОЙ ДАТЕ ДОКУМЕНТА; - СУММУ В ВАЛЮТЕ РАССЧИТЫВАТЬ В СООТВЕТСТВИИ С КУРСОМ ВАЛЮТЫ НА УСТАНОВЛЕННУЮ ВРУЧНУЮ ДАТУ ДОКУМЕНТА.
                     vldSEND_DATE AS F32A_CURR_DATE,
                     NVL(SUMM_TO_CURRENCY(SUMM_             => PI.SUM_PAY - NVL(PI.SUM_TAX, 0) - NVL(PI.SUM_TAX_DEFERRAL, 0),
                                          G_COURSE_VARIETY_ => 1,
                                          CURRENCY          => CP.G_CURRENCY,
                                          -- 25-09-2019: МАМЕТОВ СЕРИК АЛИМАМЕТОВИЧ: ПО ЗАДАЧЕ В БИТРИКСЕ №416521 БЫЛИ ДОБАВЛЕНЫ НОВЫЕ ВХОДЯЩИЕ ПЕРЕМЕННЫЕ, ДАТА ВАЛЮТИРОВАНИЯ, ДАТА ДОКУМЕНТА:
                                          -- ПРИ ФОРМИРОВАНИИ ПЛАТЕЖНОГО СООБЩЕНИЯ В ФОРМАТЕ МТ-103 УСТАНОВИТЬ: - ВОЗМОЖНОСТЬ ВЫБОРА ДАТЫ ВАЛЮТИРОВАНИЯ И ДАТЫ ДОКУМЕНТА ВРУЧНУЮ, ПРИ ЭТОМ В СЛУЧАЕ ОТСУТСТВИЯ ЗАВЕДЕННОЙ
                                          -- ВРУЧНУЮ ДАТЫ ВАЛЮТИРОВАНИЯ, СЧИТАТЬ ЕЕ РАВНОЙ ДАТЕ ДОКУМЕНТА; - СУММУ В ВАЛЮТЕ РАССЧИТЫВАТЬ В СООТВЕТСТВИИ С КУРСОМ ВАЛЮТЫ НА УСТАНОВЛЕННУЮ ВРУЧНУЮ ДАТУ ДОКУМЕНТА.
                                          WORK_DATE_        => vldFDoc_DATE),
                         0) AS FSUMM,
                     --04.05.2023: Миреев А. добавил сумму в тенге и цену валюты
                     PI.SUM_PAY - NVL(PI.SUM_TAX, 0) - NVL(PI.SUM_TAX_DEFERRAL, 0) KZT_SUM,
                     GET_CURRENCY_COURSE(G_COURSE_VARIETY_ => 1,
                                 G_CURRENCY_ => C.G_CURRENCY,
                                 WORK_DATE_ => vldFDoc_DATE) CURRENCY_COURSE,

                     ACCCODE_IN_CURRENCY(CP.G_CURRENCY) F50_GUARANTOR_ACCOUNT,
                     M.F50_GUARANTOR_RNN,
                     '1' AS FGUARANTOR_IRS,
                     '5' AS FGUARANTOR_SECO,
                     -- 31-10-2019: МАМЕТОВ СЕРИК АЛИМАМЕТОВИЧ: ПОЗВОНИЛ КУАНЫШ ИЗ НБ И СКАЗАЛ, ЧТО НАИМЕНОВАНИЕ ОТПРАВИТЕЛЯ, СТРАНА, АДРЕС ОТПРАВЛЯЛИСЬ В ВЕРХНЕМ РЕГИСТРЕ. ТАКЖЕ ПРИПИСКА К СТРАНЕ "РЕСПУБЛИКА"
                     decode(C.G_CURRENCY,
                            15,
                            'АКЦИОНЕРНОЕ ОБЩЕСТВО "ЕДИНЫЙ НАКОПИТЕЛЬНЫЙ ПЕНСИОННЫЙ ФОНД"',
                            '"UNIFIED ACCUMULATIVE PENSION FUND" JOINT STOCK COMPANY"') F50_GUARANTOR_NAME,
                     decode(C.G_CURRENCY, 15, 'Г. АЛМАТЫ, МКР. САМАЛ-2, Д.97, Н.П.13', 'ALMATY CITY, MEDEU DISTRICT, SAMAL-2 MICRODISTRICT, HOUSE NO. 97') FGUARANTOR_ADDRESS,--18.04.2022 Задача №789768 Жапаров М.С
                     decode(C.G_CURRENCY, 15, 'РЕСПУБЛИКА КАЗАХСТАН', 'REPUBLIC KAZAKHSTAN') FGUARANTOR_COUNTRY,
                     M.F50_GUARANTOR_CHIEF,
                     M.F50_GUARANTOR_MAIN_BK,
                     ADM.PARAMS.GET_SYSTEM_SETUP_PARAM('MFO_NB') AS F52B_GUARANTOR_BANK_MFO,
                     case when (CP.G_CURRENCY = 15 and GCT.CODE = 'BLR') then NULL
                          /*when (CP.G_CURRENCY = 5 and GCT.CODE = 'BLR') then
                            CP.BANK_INTERMED_SWIFT-- || '/' || CP.BANK_INTERMED_ACC*/
                          when (CP.G_CURRENCY = 15 and GCT.CODE = 'KGZ') then NULL

                          when (CP.G_CURRENCY IN (5, 12, 14) and CP.BANK_INTERMED_SWIFT IS NOT NULL) then RPAD(CP.BANK_INTERMED_SWIFT, 11, 'X')
                          else
                            CP.BANK_INTERMED_SWIFT
                     end AS F56C_INTERMED_BANK_MFO,
                     case when (CP.G_CURRENCY = 15 and GCT.CODE = 'BLR') then NULL
                          when (CP.G_CURRENCY = 15 and GCT.CODE = 'KGZ') then NULL
                          else CP.BANK_INTERMED_ACC
                     end AS F56C_INTERMED_ACCOUNT,
                     case when (CP.G_CURRENCY = 15 and GCT.CODE = 'BLR') then NULL
                          when (CP.G_CURRENCY = 15 and GCT.CODE = 'KGZ') then NULL
                          else CP.BANK_INTERMED_NAME
                     end AS  F56C_INTERMED_NAME,
                     null AS F56C_INTERMED_ADDRESS,
                     null AS F56C_INTERMED_COUNTRY,
                     case when (CP.G_CURRENCY = 15 and GCT.CODE = 'BLR') then CP.BANK_INTERMED_SWIFT
                          when (CP.G_CURRENCY = 15 and GCT.CODE = 'KGZ') then CP.BANK_INTERMED_SWIFT
                          when CP.G_CURRENCY IN (5, 12, 14) then RPAD(CP.BANK_BIK, 11, 'X')
                          else CP.BANK_BIK
                     end AS F57C_BENEF_BANK_MFO,
                     case when (CP.G_CURRENCY = 15 and GCT.CODE = 'BLR') then CP.BANK_INTERMED_ACC
                          when (CP.G_CURRENCY = 15 and GCT.CODE = 'KGZ') then CP.BANK_INTERMED_ACC
                          when (CP.G_CURRENCY IN (5, 12, 14) and CP.BANK_INTERMED_ACC IS NOT NULL) then CP.BANK_INTERMED_ACC
                          else CP.BANK_FOREIGN_ACCOUNT
                     end AS F57C_BENEF_ACCOUNT,

                     (case when (CP.G_CURRENCY = 15 and GCT.CODE = 'BLR') then CP.BANK_INTERMED_NAME
                          when (CP.G_CURRENCY = 15 and GCT.CODE = 'KGZ') then CP.BANK_INTERMED_NAME
                          else CP.BANK_NAME
                     end) AS F57C_BENEF_NAME,
                     null AS F57C_BENEF_ADDRESS,
                     (case when (CP.G_CURRENCY = 15 and GCT.CODE = 'BLR') then NULL
                          when (CP.G_CURRENCY = 15 and GCT.CODE = 'KGZ') then NULL
                          when CP.G_CURRENCY IN (5, 12, 14) then NULL
                          else GCT.NAME
                      end) AS F57C_BENEF_COUNTRY,
                     case when (CP.G_CURRENCY = 15 and GCT.CODE = 'BLR') then 'RU'
                          when (CP.G_CURRENCY = 15 and GCT.CODE = 'KGZ') then 'RU'
                          else GCT.CODE_2A
                     end AS F57C_BENEF_COUNTRYCODE,
                     null AS F50K_PAYER_ACCOUNT,
                     null AS F50K_PAYER_IDN,
                     null AS F50K_PAYER_NAME,
                     (case when (CP.G_CURRENCY = 15 and GCT.CODE = 'BLR') then CP.BANK_FOREIGN_ACCOUNT
                          when (CP.G_CURRENCY = 15 and GCT.CODE = 'KGZ') then CP.BANK_FOREIGN_ACCOUNT
                          else  CP.BANK_ACCOUNT_PERSONAL
                     end) AS F59_BENEF_ACCOUNT,
                    (CASE
                        when (CP.G_CURRENCY = 15 and GCT.CODE = 'RUS') then 'ИНН'||CP.BANK_RNN ||'*'||CP.FM || ' ' || CP.NM || ' ' || decode(CP.NO_FT, 1, NULL, CP.FT)
                        when  (CP.G_CURRENCY = 15 and GCT.CODE = 'BLR') then CP.BANK_NAME || ', БИК ' || MAIN.P_GET_STR_WITH_APOSTROPHE(CP.BANK_BIK)
                        when  (CP.G_CURRENCY = 15 and GCT.CODE = 'KGZ') then CP.BANK_NAME || ', БИК ' || MAIN.P_GET_STR_WITH_APOSTROPHE(CP.BANK_BIK)
                        when CP.G_CURRENCY IN (5, 12, 14) then CP.FM_LAT || ' ' || CP.NM_LAT || ' ' || decode(CP.NO_FT, 1, NULL, CP.FT_LAT) || ', PASS ' || CP.ID_NUM
                        else  CP.FM_LAT || ' ' || CP.NM_LAT || ' ' || decode(CP.NO_FT, 1, NULL, CP.FT_LAT)
                     end) AS F59_BENEF_NAME,
                     null AS F59_BENEF_IDN,
                     null AS F59_BENEF_KPP,
                     '4' AS F59_BENEF_ECON_SECT,
                     '2' AS F59_BENEF_IRS,
                     '9' AS F59_BENEF_SECO,
                     null AS F59_BENEF_ADDRESS,
                     GCT.NAME AS F59_BENEF_COUNTRY,
                     GCT.CODE_2A AS F59_BENEF_COUNTRYCODE,
                     '011' AS F70_KNP,
                     -- 25-09-2019: МАМЕТОВ СЕРИК АЛИМАМЕТОВИЧ: ПО ЗАДАЧЕ В БИТРИКСЕ №416521 БЫЛИ ДОБАВЛЕНЫ НОВЫЕ ВХОДЯЩИЕ ПЕРЕМЕННЫЕ, ДАТА ВАЛЮТИРОВАНИЯ, ДАТА ДОКУМЕНТА:
                     -- ПРИ ФОРМИРОВАНИИ ПЛАТЕЖНОГО СООБЩЕНИЯ В ФОРМАТЕ МТ-103 УСТАНОВИТЬ: - ВОЗМОЖНОСТЬ ВЫБОРА ДАТЫ ВАЛЮТИРОВАНИЯ И ДАТЫ ДОКУМЕНТА ВРУЧНУЮ, ПРИ ЭТОМ В СЛУЧАЕ ОТСУТСТВИЯ ЗАВЕДЕННОЙ
                     -- ВРУЧНУЮ ДАТЫ ВАЛЮТИРОВАНИЯ, СЧИТАТЬ ЕЕ РАВНОЙ ДАТЕ ДОКУМЕНТА; - СУММУ В ВАЛЮТЕ РАССЧИТЫВАТЬ В СООТВЕТСТВИИ С КУРСОМ ВАЛЮТЫ НА УСТАНОВЛЕННУЮ ВРУЧНУЮ ДАТУ ДОКУМЕНТА.
                     To_Char(vldFDoc_DATE, 'YYMMDD') AS F70_DOC_DATE,
                     null AS F70_CONT,
                     null AS F70_CONTDD,
                     null AS F70_INV,
                     decode(C.G_CURRENCY, 15,
                              case when (SUBSTR(CP.BANK_ACCOUNT_PERSONAL, 1, 5) = '40820') then '60081'
                                   when (SUBSTR(CP.BANK_ACCOUNT_PERSONAL, 1, 3) = '426') then '60081'
                                   when (SUBSTR(CP.BANK_ACCOUNT_PERSONAL, 1, 2) = 'BY') then '60085'
                                   else  '70030'
                              end,
                            NULL) AS F70_VOPER,
                     null AS F70_PAY_ASSIGN,
                     null G_JUR_PERSON_EAES, --23.08.2022: Миреев А. Заявка №323
                     To_Char(CP.P_CLAIM_PAY_OUT) P_CLAIM_PAY_OUT,
                     'OUR' AS F71A,
                     C.CODE || '/' || ACCCODE_IN_CURRENCY(CP.G_CURRENCY) AS F71B,
                     GCT.CODE AS G_COUNTRY_CODE,
                     CP.BANK_ACCOUNT_PERSONAL,
                     CP.NO_FT,
                     CP.CARDNUM,
                     C.G_CURRENCY,
                     upper(CP.FM_LAT) AS FM_LAT,
                     upper(CP.NM_LAT) AS NM_LAT,
                     upper(CP.FT_LAT) AS FT_LAT,
                     upper(CP.FM) AS FM,
                     upper(CP.NM) AS NM,
                     upper(CP.FT) AS FT,
                     To_Char(CP.P_G_REGISTRATION_TYPE) P_G_REGISTRATION_TYPE,
                     To_Char(PT.P_G_PAY_OUT_TYPE) P_G_PAY_OUT_TYPE,
                     To_Char(CP.P_CONTRACT) P_CONTRACT,
                     To_Char(CP.BANK_IS_RECIPIENT_ACCOUNT) BANK_IS_RECIPIENT_ACCOUNT,
                     CP.FMSETTLOR,
                     CP.NMSETTLOR,
                     CP.FTSETTLOR,
                     CP.FMTRUSTEE,
                     CP.NMTRUSTEE,
                     CP.FTTRUSTEE,
                     CP.BANK_RNN,
                     CP.BANK_NAME,
                     CP.BANK_BIK,
                     CP.ID_NUM,
                     CP.BANK_BRANCH_NAME,
                     M.O_MT,
                     CP.ADDRESS,
                     CP.BANK_ADDR,
                     CP.BANK_INTERMED_ADDR
                from MAIN.P_CLAIM_PAY_OUT CP,
                     MAIN.P_G_PAY_OUT_SUB_TYPE PT,
                     (select DISTINCT aa.ID from ADM.T_INT_TABLE# aa) T, -- 11.04.2022: Миреев А. добавил distinct чтоб убрать дубли
                     MAIN.G_CURRENCY        C,
                     MAIN.P_PAYMENT_INFO    PI,
                     MAIN.O_MT              M,
                     MAIN.G_COUNTRY         GC,
                     MAIN.G_COUNTRY         GCT
               where CP.P_G_PAY_OUT_SUB_TYPE = PT.P_G_PAY_OUT_SUB_TYPE
                 and CP.BANK_IS_FOREIGN = 1
                 and CP.P_CLAIM_PAY_OUT = T.ID
                 and CP.G_CURRENCY = C.G_CURRENCY
                 and CP.P_CLAIM_PAY_OUT = PI.P_CLAIM_PAY_OUT
                 and PI.O_MT = M.O_MT
                 and CP.G_COUNTRY = GC.G_COUNTRY(+)
                 and CP.BANK_COUNTRY = GCT.G_COUNTRY(+)
                 and M.state in (0,1,2)
                 and M.f32a_curr_date>vldFCurr_Date-10
                 --05.09.2022: Миреев А. Берем заявления только у кого НЕ ЗАПОЛНЕН в заявлении "КО Бенефициар"
                 and NOT EXISTS (select 1 from G_JUR_PERSON_EAES PE where PE.G_JUR_PERSON_EAES = CP.BANK_G_JUR_PERSON)
               )
                    union
                    --05.09.2022: Миреев А. Запрос вытаскивает только те заявления где ЗАПОЛНЕНО поле "КО Бенефициар", в остальном почти идентичен верхнему запросу
                   (select MIN(NVL(To_Char(vldFDoc_DATE, 'DDMM')|| LPAD(To_Char(PI.NUM_CLAIM_PAY_OUT_TRANSFER), 3, '0'), CP.CLAIM_NUM)) AS F20,
                           C.CODE,
                           vldSEND_DATE AS F32A_CURR_DATE,
                           --05.10.2022: Миреев А. Берется из одного O_MT одинаковая сумма
                           max(NVL(SUMM_TO_CURRENCY(SUMM_             => nvl(M.F32A_SUMM,0), --PI.SUM_PAY - NVL(PI.SUM_TAX, 0) - NVL(PI.SUM_TAX_DEFERRAL, 0),
                                                G_COURSE_VARIETY_ => 1,
                                                CURRENCY          => CP.G_CURRENCY,
                                                WORK_DATE_        => vldFDoc_DATE),
                               0)) AS FSUMM,
                           --04.05.2023: Миреев А. добавил сумму в тенге и цену валюты
                           max(M.F32A_SUMM) KZT_SUM, --max(PI.SUM_PAY - NVL(PI.SUM_TAX, 0) - NVL(PI.SUM_TAX_DEFERRAL, 0)) KZT_SUM,
                           max(GET_CURRENCY_COURSE(G_COURSE_VARIETY_ => 1,
                                       G_CURRENCY_ => C.G_CURRENCY,
                                       WORK_DATE_ => vldFDoc_DATE)) CURRENCY_COURSE,

                           max(ACCCODE_IN_CURRENCY(CP.G_CURRENCY)) F50_GUARANTOR_ACCOUNT,
                           max(M.F50_GUARANTOR_RNN) F50_GUARANTOR_RNN,
                           '1' AS FGUARANTOR_IRS,
                           '5' AS FGUARANTOR_SECO,
                           max(decode(C.G_CURRENCY,
                                  15,
                                  'АКЦИОНЕРНОЕ ОБЩЕСТВО "ЕДИНЫЙ НАКОПИТЕЛЬНЫЙ ПЕНСИОННЫЙ ФОНД"',
                                  '"UNIFIED ACCUMULATIVE PENSION FUND" JOINT STOCK COMPANY"')) F50_GUARANTOR_NAME,
                           max(decode(C.G_CURRENCY, 15, 'Г. АЛМАТЫ, МКР. САМАЛ-2, Д.97, Н.П.13', 'ALMATY CITY, MEDEU DISTRICT, SAMAL-2 MICRODISTRICT, HOUSE NO. 97')) FGUARANTOR_ADDRESS,--18.04.2022 Задача №789768 Жапаров М.С
                           max(decode(C.G_CURRENCY, 15, 'РЕСПУБЛИКА КАЗАХСТАН', 'REPUBLIC KAZAKHSTAN')) FGUARANTOR_COUNTRY,
                           max(M.F50_GUARANTOR_CHIEF) F50_GUARANTOR_CHIEF,
                           max(M.F50_GUARANTOR_MAIN_BK) F50_GUARANTOR_MAIN_BK,
                           max(ADM.PARAMS.GET_SYSTEM_SETUP_PARAM('MFO_NB')) AS F52B_GUARANTOR_BANK_MFO,
                           max(decode(PE.G_COUNTRY,
                                        BELARUSSIA, null,
                                       (case when (CP.G_CURRENCY = 15 and GCT.CODE = 'BLR') then
                                              NULL

                                            when (CP.G_CURRENCY = 15 and GCT.CODE = 'KGZ') then
                                              NULL

                                            when (CP.G_CURRENCY IN (5, 12, 14) and CP.BANK_INTERMED_SWIFT IS NOT NULL) then
                                              RPAD(CP.BANK_INTERMED_SWIFT, 11, 'X')
                                            else
                                              CP.BANK_INTERMED_SWIFT
                                        end))
                           ) AS F56C_INTERMED_BANK_MFO,
                           max((case when (CP.G_CURRENCY = 15 and GCT.CODE = 'BLR') then
                                  NULL
                                when (CP.G_CURRENCY = 15 and GCT.CODE = 'KGZ') then
                                  NULL

                                else
                                  CP.BANK_INTERMED_ACC
                           end)) AS F56C_INTERMED_ACCOUNT,
                           max(decode(PE.G_COUNTRY,
                                        BELARUSSIA, null,
                                       (case when (CP.G_CURRENCY = 15 and GCT.CODE = 'BLR') then
                                          NULL
                                        when (CP.G_CURRENCY = 15 and GCT.CODE = 'KGZ') then
                                          NULL

                                        else
                                          CP.BANK_INTERMED_NAME
                                        end)
                                )) AS  F56C_INTERMED_NAME,

                           null AS F56C_INTERMED_ADDRESS,
                           null AS F56C_INTERMED_COUNTRY,
                           max((case when (CP.G_CURRENCY = 15 and GCT.CODE = 'BLR') then
                                  CP.BANK_INTERMED_SWIFT
                                when (CP.G_CURRENCY = 15 and GCT.CODE = 'KGZ') then
                                  CP.BANK_INTERMED_SWIFT

                                when CP.G_CURRENCY IN (5, 12, 14) then
                                  RPAD(CP.BANK_BIK, 11, 'X')
                                else
                                  CP.BANK_BIK
                           end)) AS F57C_BENEF_BANK_MFO,
                           max((case when (CP.G_CURRENCY = 15 and GCT.CODE = 'BLR') then
                                  CP.BANK_INTERMED_ACC
                                when (CP.G_CURRENCY = 15 and GCT.CODE = 'KGZ') then
                                  CP.BANK_INTERMED_ACC
                                when (CP.G_CURRENCY IN (5, 12, 14) and CP.BANK_INTERMED_ACC IS NOT NULL) then
                                  CP.BANK_INTERMED_ACC
                                else
                                  CP.BANK_FOREIGN_ACCOUNT
                           end)) AS F57C_BENEF_ACCOUNT,

                           --23.08.2022: Миреев А. Заявка №323
                           max(decode(PE.G_COUNTRY,108,PE.BANK_NAME,upper(JP.NAME_NAT))) AS F57C_BENEF_NAME,
                           null AS F57C_BENEF_ADDRESS,
                           max(decode(PE.G_COUNTRY,
                                        BELARUSSIA,'BELARUS',
                                       (case when (CP.G_CURRENCY = 15 and GCT.CODE = 'BLR') then
                                          NULL
                                        when (CP.G_CURRENCY = 15 and GCT.CODE = 'KGZ') then
                                          NULL
                                        when CP.G_CURRENCY IN (5, 12, 14) then
                                          NULL
                                        else
                                          GCT.NAME
                                        end))) AS F57C_BENEF_COUNTRY,
                           max((case when (CP.G_CURRENCY = 15 and GCT.CODE = 'BLR') then
                                  'RU'
                                when (CP.G_CURRENCY = 15 and GCT.CODE = 'KGZ') then
                                  'RU'
                                else
                                  GCT.CODE_2A
                           end)) AS F57C_BENEF_COUNTRYCODE,
                           null AS F50K_PAYER_ACCOUNT,
                           null AS F50K_PAYER_IDN,
                           null AS F50K_PAYER_NAME,
                           --23.08.2022: Миреев А. Заявка №323
                           max(PE.ACC_2) AS F59_BENEF_ACCOUNT, --КАЗНАЧЕЙСКИЙ СЧЕТ/СЧЕТ(28 ЗНАКОВ)

                           --23.08.2022: Миреев А. Заявка №323
                           max(decode(PE.G_COUNTRY, --если страна
                                            RUSSIA,     ('ИНН'||JP.RNN||'.'||'КПП'||PE.KPP||'*'||upper(PE.BANK_NAME)), --новый формат = Россия
                                            BELARUSSIA, (PE.BANK_NAME||', UNP '||JP.RNN), --Беларусь
                                            KYRGYZSTAN, (JP.SHORT_NAME),
                                             (CASE
                                                   when (CP.G_CURRENCY = 15 and GCT.CODE = 'RUS') then
                                                     'ИНН'||CP.BANK_RNN ||'*'||CP.FM || ' ' || CP.NM || ' ' || decode(CP.NO_FT, 1, NULL, CP.FT)
                                                   when  (CP.G_CURRENCY = 15 and GCT.CODE = 'BLR') then
                                                     CP.BANK_NAME || ', БИК ' || MAIN.P_GET_STR_WITH_APOSTROPHE(CP.BANK_BIK)
                                                   when  (CP.G_CURRENCY = 15 and GCT.CODE = 'KGZ') then
                                                     CP.BANK_NAME || ', БИК ' || MAIN.P_GET_STR_WITH_APOSTROPHE(CP.BANK_BIK)
                                                   when CP.G_CURRENCY IN (5, 12, 14) then
                                                     CP.FM_LAT || ' ' || CP.NM_LAT || ' ' || decode(CP.NO_FT, 1, NULL, CP.FT_LAT) || ', PASS ' || CP.ID_NUM
                                                   else  CP.FM_LAT || ' ' || CP.NM_LAT || ' ' || decode(CP.NO_FT, 1, NULL, CP.FT_LAT)
                                              end) --старый формат
                                   )) AS F59_BENEF_NAME,
                           null AS F59_BENEF_IDN,
                           null AS F59_BENEF_KPP,
                           '4' AS F59_BENEF_ECON_SECT,
                           '2' AS F59_BENEF_IRS,
                           '5' AS F59_BENEF_SECO,
                           null AS F59_BENEF_ADDRESS,
                           max(decode(PE.G_COUNTRY,BELARUSSIA,'BELARUS',GCT.NAME)) AS F59_BENEF_COUNTRY,
                           max(GCT.CODE_2A) AS F59_BENEF_COUNTRYCODE,
                           '105' AS F70_KNP,
                           To_Char(vldFDoc_DATE, 'YYMMDD') AS F70_DOC_DATE,
                           null AS F70_CONT,
                           null AS F70_CONTDD,
                           null AS F70_INV,
                           max(decode(C.G_CURRENCY, 15,
                                    case when (SUBSTR(CP.BANK_ACCOUNT_PERSONAL, 1, 5) = '40820') then
                                              '60081'
                                         when (SUBSTR(CP.BANK_ACCOUNT_PERSONAL, 1, 3) = '426') then
                                              '60081'
                                         when (SUBSTR(CP.BANK_ACCOUNT_PERSONAL, 1, 2) = 'BY') then
                                              '60085'
                                         else  '70030'
                                    end,
                                  NULL)) AS F70_VOPER,
                           --23.08.2022: Миреев А. Заявка №323
                     -- 07.02.2025 OlzhasT внес изменения в назначение платежа Задача №1170835
                           max(decode(PE.G_COUNTRY,
                                  BELARUSSIA, '05508, PAYMENT OF PENSION UNDER THE AGREEMENT (EAEU) (for '||MAIN.F_GET_PREV_QUARTER_NUM(vldSEND_DATE)||' QUARTER '||F_GET_PREV_YEAR(vldSEND_DATE)||')',
                                  KYRGYZSTAN, 'PAYMENT OF PENSION UNDER THE AGREEMENT (EAEU) (for '||MAIN.F_GET_PREV_QUARTER_NUM(vldSEND_DATE)||' QUARTER '||F_GET_PREV_YEAR(vldSEND_DATE)||'), TTC21211100',
                                              'ВЫПЛАТА ПЕНСИИ ПО СОГЛАШЕНИЮ (ЕАЭС) (ЗА '||MAIN.F_GET_PREV_QUARTER_NUM(vldSEND_DATE,2)||' КВАРТАЛ '||F_GET_PREV_YEAR(vldSEND_DATE)||'г.)'
                                  ))
                           AS F70_PAY_ASSIGN,
                           max(PE.G_JUR_PERSON_EAES) G_JUR_PERSON_EAES, --23.08.2022: Миреев А. Заявка №323
                           NVL(decode(PE.G_COUNTRY,
                                            RUSSIA, null ,
                                            BELARUSSIA,NULL,
                                            KYRGYZSTAN,NULL,
                                            CP.P_CLAIM_PAY_OUT),
                               max(CP.P_CLAIM_PAY_OUT)) P_CLAIM_PAY_OUT,
                           'OUR' AS F71A,
                           max(C.CODE || '/' || ACCCODE_IN_CURRENCY(CP.G_CURRENCY)) AS F71B,
                           max(GCT.CODE) AS G_COUNTRY_CODE,
                           max(CP.BANK_ACCOUNT_PERSONAL) BANK_ACCOUNT_PERSONAL,
                           max(CP.NO_FT) NO_FT,
                           max(CP.CARDNUM) CARDNUM,
                           max(C.G_CURRENCY) G_CURRENCY,
                           max(decode(PE.G_COUNTRY,RUSSIA,NULL,BELARUSSIA,NULL,KYRGYZSTAN,NULL,upper(CP.FM_LAT))) AS FM_LAT,
                           max(decode(PE.G_COUNTRY,RUSSIA,NULL,BELARUSSIA,NULL,KYRGYZSTAN,NULL,upper(CP.NM_LAT))) AS NM_LAT,
                           max(decode(PE.G_COUNTRY,RUSSIA,NULL,BELARUSSIA,NULL,KYRGYZSTAN,NULL,upper(CP.FT_LAT))) AS FT_LAT,
                           max(decode(PE.G_COUNTRY,RUSSIA,NULL,BELARUSSIA,NULL,KYRGYZSTAN,NULL,upper(CP.FM))) AS FM,
                           max(decode(PE.G_COUNTRY,RUSSIA,NULL,BELARUSSIA,NULL,KYRGYZSTAN,NULL,upper(CP.NM))) AS NM,
                           max(decode(PE.G_COUNTRY,RUSSIA,NULL,BELARUSSIA,NULL,KYRGYZSTAN,NULL,upper(CP.FT))) AS FT,
                           max(decode(PE.G_COUNTRY,RUSSIA,NULL,BELARUSSIA,NULL,KYRGYZSTAN,NULL,CP.P_G_REGISTRATION_TYPE)) P_G_REGISTRATION_TYPE,
                           max(decode(PE.G_COUNTRY,RUSSIA,NULL,BELARUSSIA,NULL,KYRGYZSTAN,NULL,PT.P_G_PAY_OUT_TYPE)) P_G_PAY_OUT_TYPE,
                           max(decode(PE.G_COUNTRY,RUSSIA,NULL,BELARUSSIA,NULL,KYRGYZSTAN,NULL,CP.P_CONTRACT)) P_CONTRACT,
                           max(decode(PE.G_COUNTRY,RUSSIA,NULL,BELARUSSIA,NULL,KYRGYZSTAN,NULL,CP.BANK_IS_RECIPIENT_ACCOUNT)) BANK_IS_RECIPIENT_ACCOUNT,
                           max(decode(PE.G_COUNTRY,RUSSIA,NULL,BELARUSSIA,NULL,KYRGYZSTAN,NULL,CP.FMSETTLOR)) FMSETTLOR,
                           max(decode(PE.G_COUNTRY,RUSSIA,NULL,BELARUSSIA,NULL,KYRGYZSTAN,NULL,CP.NMSETTLOR)) NMSETTLOR,
                           max(decode(PE.G_COUNTRY,RUSSIA,NULL,BELARUSSIA,NULL,KYRGYZSTAN,NULL,CP.FTSETTLOR)) FTSETTLOR,
                           max(decode(PE.G_COUNTRY,RUSSIA,NULL,BELARUSSIA,NULL,KYRGYZSTAN,NULL,CP.FMTRUSTEE)) FMTRUSTEE,
                           max(decode(PE.G_COUNTRY,RUSSIA,NULL,BELARUSSIA,NULL,KYRGYZSTAN,NULL,CP.NMTRUSTEE)) NMTRUSTEE,
                           max(decode(PE.G_COUNTRY,RUSSIA,NULL,BELARUSSIA,NULL,KYRGYZSTAN,NULL,CP.FTTRUSTEE)) FTTRUSTEE,
                           max(CP.BANK_RNN) BANK_RNN,
                           max(CP.BANK_NAME) BANK_NAME,
                           max(CP.BANK_BIK) BANK_BIK,
                           max(decode(PE.G_COUNTRY,RUSSIA,NULL,BELARUSSIA,NULL,KYRGYZSTAN,NULL,CP.ID_NUM)) ID_NUM,
                           max(CP.BANK_BRANCH_NAME) BANK_BRANCH_NAME,
                           max(M.O_MT) O_MT,
                           null ADDRESS,
                           null BANK_ADDR,
                           null BANK_INTERMED_ADDR
                      from MAIN.P_CLAIM_PAY_OUT CP,
                           MAIN.P_G_PAY_OUT_SUB_TYPE PT,
                           (select CP.P_CLAIM_PAY_OUT
                              from MAIN.P_OPR PO
                                  ,MAIN.P_G_OPRKND K
                                  ,MAIN.P_LT_OPR_CLAIM LT
                                  ,MAIN.P_CLAIM_PAY_OUT CP
                             where PO.WORKING_DATE = WORKING_DATE_
                               and K.P_G_GROUP_OPRKND = 9
                               and PO.P_G_OPRKND = K.P_G_OPRKND
                               and LT.P_OPR = PO.P_OPR
                               and CP.P_CLAIM_PAY_OUT = LT.P_CLAIM_PAY_OUT
                               and CP.BANK_IS_FOREIGN = 1) T, -- 11.04.2022: Миреев А.
                           MAIN.G_CURRENCY        C,
                           MAIN.P_PAYMENT_INFO    PI,
                           MAIN.O_MT              M,
                           MAIN.G_COUNTRY         GC,
                           MAIN.G_COUNTRY         GCT,
                           MAIN.G_JUR_PERSON_EAES PE, --23.08.2022: Миреев А. Заявка №323
                           MAIN.G_JUR_PERSON      JP, --23.08.2022: Миреев А. Заявка №323
                           adm.T_INT_TABLE1#      it1
                     where CP.P_G_PAY_OUT_SUB_TYPE = PT.P_G_PAY_OUT_SUB_TYPE
                       and CP.BANK_IS_FOREIGN = 1
                       and CP.P_CLAIM_PAY_OUT = T.P_CLAIM_PAY_OUT
                       and CP.G_CURRENCY = C.G_CURRENCY
                       and CP.P_CLAIM_PAY_OUT = PI.P_CLAIM_PAY_OUT
                       and PI.O_MT = M.O_MT
                       and CP.G_COUNTRY = GC.G_COUNTRY(+)
                       and CP.BANK_COUNTRY = GCT.G_COUNTRY(+)
                       and M.F32A_CURR_DATE = vldFCurr_Date
                       and PE.G_JUR_PERSON_EAES = CP.BANK_G_JUR_PERSON --23.08.2022: Миреев А. Заявка №323
                       and JP.G_JUR_PERSON = PE.G_JUR_PERSON_EAES --23.08.2022: Миреев А. Заявка №323
                       and jp.g_jur_person = it1.id
                     group by PE.G_JUR_PERSON_EAES,
                              C.CODE,
                              PE.G_COUNTRY,
                              decode(PE.G_COUNTRY,RUSSIA,NULL,BELARUSSIA,NULL,KYRGYZSTAN,NULL,CP.P_CLAIM_PAY_OUT)
                     )
                   order by 1
               ) loop
    begin
      vlcTmp      := vlcTmp||REC.P_CLAIM_PAY_OUT;
      vlcLogStep  := 'P_CLAIM_PAY_OUT['||REC.P_CLAIM_PAY_OUT||'] F32A_SUMM['||REC.KZT_SUM||'] CP.G_CURRENCY['||REC.G_CURRENCY||'] vldFDoc_DATE['||vldFDoc_DATE||'] CURRENCY_COURSE['||REC.CURRENCY_COURSE||']';

      if REC.G_JUR_PERSON_EAES IS NOT null then
        pl_O_MT103_del(REC.P_CLAIM_PAY_OUT); --- Надо удалить старые O_MT103 которые возможно были ранее сформированы
      end if;
      -- 25-10-2019: МАМЕТОВ СЕРИК АЛИМАМЕТОВИЧ: НЕОБХОДИМО ПРИ ФОРМИРОВАНИИ НАЗНАЧЕНИИ ПЛАТЕЖА И НАИМЕНОВАНИЯ БЕНЕФИЦИАРА УЧИТЫВАТЬ ЧЕРЕЗ КОГО ПОДАННО ЗАЯВЛЕНИЕ
      -- ЛИЧНО
      if REC.P_G_REGISTRATION_TYPE = 1 then
        if (REC.P_G_PAY_OUT_TYPE NOT IN (3, 4)) then
          begin
            select GP.FM, GP.NM, GP.FT
            into FM_, NM_, FT_
            from MAIN.G_NAT_PERSON GP, MAIN.P_CONTRACT P
            where GP.G_PERSON = P.G_PERSON_RECIPIENT
              and P.P_CONTRACT = REC.P_CONTRACT;
          exception
            when others then
              FM_ := REC.FM; NM_ := REC.NM; FT_ := REC.FT;
          end;

          if REC.NO_FT = 1 then
            FT_ := NULL;
          end if;
        else
          FM_  := REC.FM; NM_  := REC.NM; FT_  := REC.FT;
        end if;
      else

        if REC.BANK_IS_RECIPIENT_ACCOUNT = 2 then  -- Через поверенного
          if (REC.P_G_PAY_OUT_TYPE NOT IN (3, 4)) then  -- На лицевой счет получателя
            begin
              select GP.FM, GP.NM, GP.FT
              into FM_, NM_, FT_
              from MAIN.G_NAT_PERSON GP, MAIN.P_CONTRACT P
              where GP.G_PERSON = P.G_PERSON_RECIPIENT
                and P.P_CONTRACT = REC.P_CONTRACT;
            exception
              when others then
                FM_ := REC.FM; NM_ := REC.NM; FT_ := REC.FT;
            end;

            if REC.NO_FT = 1 then
              FT_ := NULL;
            end if;
          else
            FM_ := REC.FM; NM_ := REC.NM; FT_ := REC.FT;
          end if;
        elsif REC.BANK_IS_RECIPIENT_ACCOUNT = 1 then  -- На лицевой счет доверителя
          FM_ := REC.FMSETTLOR; NM_ := REC.NMSETTLOR; FT_ := REC.FTSETTLOR;
        else -- На лицевой счет поверенного
          FM_ := REC.FMTRUSTEE; NM_ := REC.NMTRUSTEE; FT_ := REC.FTTRUSTEE;
        end if;
      end if;

      if REC.P_G_PAY_OUT_TYPE=5 and REC.G_CURRENCY = 15 then -- Выплата в связи с выездом на ПМЖ за пределы РК
        select decode(REC.G_COUNTRY_CODE, 'BLR','СЧ.'||
         main.P_GET_STR_WITH_APOSTROPHE(REC.BANK_ACCOUNT_PERSONAL) || ', ' ||
          'Пенсионная выплата в связи с выездом на ПМЖ за пределы РК согласно Социального кодекса РК '
         ||upper(REC.FM) || ' ' || upper(REC.NM) || ' ' || decode(REC.NO_FT, 1, NULL, upper(REC.FT)),
         'Пенсионная выплата в связи с выездом на ПМЖ за пределы РК согласно Социального кодекса РК '
         ||upper(REC.FM) || ' ' || upper(REC.NM) || ' ' || decode(REC.NO_FT, 1, NULL, upper(REC.FT))
       )
       into F70_PAY_ASSIGN_ from dual;
      elsif REC.P_G_PAY_OUT_TYPE=5 and REC.G_CURRENCY <> 15 then
        select 'PENSION PAYMENT IN CONNECTION WITH THE DEPARTURE FOR PERMANENT RESIDENCE OUTSIDE OF THE REPUBLIC OF KAZAKHSTAN ACCORDING TO THE SOCIAL CODE OF THE REPUBLIC OF KAZAKHSTAN '||upper(REC.FM_LAT) || ' ' || upper(REC.NM_LAT) || ' ' || decode(REC.NO_FT, 1, NULL, upper(REC.FT_LAT))
        into F70_PAY_ASSIGN_ from dual;
      elsif REC.P_G_PAY_OUT_TYPE=2 and REC.G_CURRENCY = 15 then -- Выплата по достижению возраста
        select 'Пенсионная выплата по возрасту согласно Социального кодекса РК '||upper(REC.FM) || ' ' || upper(REC.NM) || ' ' || decode(REC.NO_FT, 1, NULL, upper(REC.FT))
        into F70_PAY_ASSIGN_ from dual;
      elsif REC.P_G_PAY_OUT_TYPE=2 and REC.G_CURRENCY <>15 then -- Выплата по достижению возраста
        select 'AGE-BASED PAYMENTS OF PENSION SAVINGS ACCORDING TO THE SOCIAL CODE OF THE REPUBLIC OF KAZAKHSTAN '||upper(REC.FM_LAT) || ' ' || upper(REC.NM_LAT) || ' ' || decode(REC.NO_FT, 1, NULL, upper(REC.FT_LAT))
        into F70_PAY_ASSIGN_ from dual;
      elsif REC.P_G_PAY_OUT_TYPE=3 and REC.G_CURRENCY = 15 then -- Выплата на погребение
        select 'Пенсионная выплата на погребение согласно Социального кодекса РК '||upper(REC.FM) || ' ' || upper(REC.NM) || ' ' || decode(REC.NO_FT, 1, NULL, upper(REC.FT))
        into F70_PAY_ASSIGN_ from dual;
      elsif REC.P_G_PAY_OUT_TYPE=3 and REC.G_CURRENCY <>15 then -- Выплата на погребение
        select 'PAYMENTS OF PENSION SAVINGS FOR BURIAL ACCORDING TO THE SOCIAL CODE OF THE REPUBLIC OF KAZAKHSTAN '||upper(REC.FM_LAT) || ' ' || upper(REC.NM_LAT) || ' ' || decode(REC.NO_FT, 1, NULL, upper(REC.FT_LAT))
        into F70_PAY_ASSIGN_ from dual;
      elsif REC.P_G_PAY_OUT_TYPE=4 and REC.G_CURRENCY = 15 then -- Выплата наследникам
        select 'Пенсионная выплата по наследству согласно Социального кодекса РК '||upper(REC.FM) || ' ' || upper(REC.NM) || ' ' || decode(REC.NO_FT, 1, NULL, upper(REC.FT))
        into F70_PAY_ASSIGN_ from dual;
      elsif REC.P_G_PAY_OUT_TYPE=4 and REC.G_CURRENCY <>15 then -- Выплата наследникам
        select 'PAYMENTS OF PENSION BY INHERITANCE ACCORDING TO THE SOCIAL CODE OF THE REPUBLIC OF KAZAKHSTAN '||upper(REC.FM_LAT) || ' ' || upper(REC.NM_LAT) || ' ' || decode(REC.NO_FT, 1, NULL, upper(REC.FT_LAT))
        into F70_PAY_ASSIGN_ from dual;
      elsif REC.P_G_PAY_OUT_TYPE=8 and REC.G_CURRENCY = 15 then -- Выплата инвалидам
        select 'Пенсионная выплата по инвалидности согласно Социального кодекса РК '||upper(REC.FM) || ' ' || upper(REC.NM) || ' ' || decode(REC.NO_FT, 1, NULL, upper(REC.FT))
        into F70_PAY_ASSIGN_ from dual;
      elsif REC.P_G_PAY_OUT_TYPE=8 and REC.G_CURRENCY <>15 then -- Выплата инвалидам
        select 'PAYMENTS OF PENSION SAVINGS FOR DISABILITY ACCORDING TO THE SOCIAL CODE OF THE REPUBLIC OF KAZAKHSTAN '||upper(REC.FM_LAT) || ' ' || upper(REC.NM_LAT) || ' ' || decode(REC.NO_FT, 1, NULL, upper(REC.FT_LAT))
        into F70_PAY_ASSIGN_ from dual;
      elsif REC.G_CURRENCY = 15 and REC.G_COUNTRY_CODE = 'BLR' then
        select 'ВО ВКЛАД  ' || upper(FM_) || ' ' || upper(NM_) || ' ' || decode(REC.NO_FT, 1, NULL, upper(FT_)) || ', СЧ.' || MAIN.P_GET_STR_WITH_APOSTROPHE(REC.BANK_ACCOUNT_PERSONAL)
        into F70_PAY_ASSIGN_ from dual;
      elsif REC.G_CURRENCY = 15 and REC.G_COUNTRY_CODE = 'KGZ' then
        select 'ВО ВКЛАД  ' || upper(FM_) || ' ' || upper(NM_) || ' ' || decode(REC.NO_FT, 1, NULL, upper(FT_)) || ', СЧ.' || MAIN.P_GET_STR_WITH_APOSTROPHE(REC.BANK_ACCOUNT_PERSONAL)
        into F70_PAY_ASSIGN_ from dual;
      else
        select decode(REC.CARDNUM, NULL,
                      decode(REC.G_CURRENCY,
                             15,
                             'ВО ВКЛАД  ' || upper(FM_) || ' ' || upper(NM_) || ' ' || decode(REC.NO_FT, 1, NULL, upper(FT_)),
                             'IN DEPOSIT ' || upper(REC.FM_LAT) || ' ' || upper(REC.NM_LAT) || ' ' || decode(REC.NO_FT, 1, NULL, upper(REC.FT_LAT))),
                      decode(REC.G_CURRENCY,
                             15,
                             'ВО ВКЛАД  ' || upper(FM_) || ' ' || upper(NM_) || ' ' ||
                             decode(REC.NO_FT, 1, NULL, upper(FT_)) || ' НОМЕР КАРТЫ ' || REC.CARDNUM,
                             'IN DEPOSIT ' || upper(REC.FM_LAT) || ' ' || upper(REC.NM_LAT) || ' ' || decode(REC.NO_FT, 1, NULL, upper(REC.FT_LAT)) || ' CARD NO ' || REC.CARDNUM)
                     )
        into F70_PAY_ASSIGN_
        from DUAL;
      end if;


      if REC.G_CURRENCY = 15 and REC.G_COUNTRY_CODE = 'RUS' then
        select 'ИНН'||REC.BANK_RNN ||'*'||FM_ || ' ' || NM_ || ' ' || decode(REC.NO_FT, 1, NULL, FT_)
        into F59_BENEF_NAME_
        from DUAL;
      elsif REC.G_CURRENCY = 15 and REC.G_COUNTRY_CODE = 'BLR' then
        F59_BENEF_NAME_ := REC.BANK_NAME || ', БИК ' || MAIN.P_GET_STR_WITH_APOSTROPHE(REC.BANK_BIK);
      elsif REC.G_CURRENCY = 15 and REC.G_COUNTRY_CODE = 'KGZ' then
        F59_BENEF_NAME_ := REC.BANK_NAME || ', БИК ' || MAIN.P_GET_STR_WITH_APOSTROPHE(REC.BANK_BIK);

      elsif REC.G_CURRENCY IN (5, 12, 14) then
        select REC.FM_LAT || ' ' || REC.NM_LAT || ' ' || decode(REC.NO_FT, 1, NULL, REC.FT_LAT) || ', PASS ' || REC.ID_NUM
        into F59_BENEF_NAME_
        from DUAL;
      else
        select REC.FM_LAT || ' ' || REC.NM_LAT || ' ' || decode(REC.NO_FT, 1, NULL, REC.FT_LAT)
        into F59_BENEF_NAME_
        from DUAL;
      end if;

      if REC.G_JUR_PERSON_EAES IS NOT null then  --22.08.2022: Миреев А. Если этот платеж ЕАЭС, то назначение платежа берем из REC.F70_PAY_ASSIGN или REC.F70_PAY_ASSIGN
        F70_PAY_ASSIGN_ := NULL;
        F59_BENEF_NAME_ := NULL;
      end if;

      -- 07-03-2020: МАМЕТОВ СЕРИК АЛИМАМЕТОВИЧ: ДОБАВИЛ НОВОЕ ПОЛЕ F72 ИНФОРМАЦИЯ ОТПРАВИТЕЛЯ ПОЛУЧАТЕЛЮ
      -- 1)  ПРИ ФОРМИРОВАНИИ "ЗАЯВЛЕНИЯ НА ПЕРЕВОД ДЕНЕГ МТ-103" ДОБАВИТЬ ПОЛЕ В ФОРМАТ МТ-103 :72:
      -- ИНФОРМАЦИЯ ОТПРАВИТЕЛЯ ПОЛУЧАТЕЛЮ ДЛЯ ПЕРЕВОДОВ В ИНОСТРАННОЙ ВАЛЮТЕ В USD, EUR, GBP, В СТРАНУ БЕЛАРУСЬ В USD:
      -- ДАННОЕ ПОЛЕ ВСЕГДА ДОЛЖНО НАЧИНАТЬСЯ СО СЛЕДУЮЩИХ КОДОВЫХ СЛОВ, ЗАКЛЮЧЕННЫХ МЕЖДУ СЛЭШАМИ: /ACC/ - ИНФОРМАЦИЯ ДЛЯ БАНКА,
      -- ГДЕ ИМЕЕТ СЧЕТ БЕНЕФИЦИАР: НОМЕР СЧЕТА, ФИЛИАЛ, ГОРОД (ЕСЛИ ОТЛИЧЕН ОТ ИНФОРМАЦИИ ИЗ СПРАВОЧНИКА SWIFT-БИК-ОВ) (134 СИМВОЛА).
      -- ПОСЛЕ КОДОВОГО СЛОВА /ACC/ ДАННЫЕ ДОЛЖНЫ ЗАПОЛНЯТЬСЯ СО СЛЕДУЮЩЕГО ПОЛЯ ИАИС-2 - КЛИЕНТЫ - ЗАЯВЛЕНИЯ НА ВЫПЛАТУ - БАНКОВСКИЕ РЕКВИЗИТЫ - НАИМЕНОВАНИЯ ФИЛ. /ОТД-НИЯ.
      -- 2)  ПРИ ФОРМИРОВАНИИ "ЗАЯВЛЕНИЯ НА ПЕРЕВОД ДЕНЕГ МТ-103" ДОБАВИТЬ ПОЛЕ В ФОРМАТ МТ-103 :72: ИНФОРМАЦИЯ ОТПРАВИТЕЛЯ ПОЛУЧАТЕЛЮ ДЛЯ ПЕРЕВОДОВ В ИНОСТРАННОЙ ВАЛЮТЕ В RUB, В СТРАНУ БЕЛАРУСЬ В RUB:
      -- ДАННОЕ ПОЛЕ ВСЕГДА ДОЛЖНО НАЧИНАТЬСЯ СО СЛЕДУЮЩИХ КОДОВЫХ СЛОВ, ЗАКЛЮЧЕННЫХ МЕЖДУ СЛЭШАМИ: /NZP/ - ДЛЯ ПРОДОЛЖЕНИЯ ИНФОРМАЦИИ О НАЗНАЧЕНИЕ ПЛАТЕЖА (63 СИМВОЛА).
      -- ДАННЫЕ ДОЛЖНЫ ЗАПОЛНЯТЬСЯ, ЕСЛИ В ПОЛЕ :70: ПРЕВЫШАЕТ (130 СИМВОЛА RUB), (128 СИМВОЛА БЕЛАРУСЬ RUB).
      if REC.G_CURRENCY IN (5, 12, 14) then
        F72_ := SUBSTR('/ACC/' ||REC.BANK_BRANCH_NAME, 1, 134);
      elsif REC.G_CURRENCY = 15 then
        if REC.G_COUNTRY_CODE = 'BLR' then
          declare
            v_fio  varchar2(200);
            v_text varchar2(500);
          begin
            -- ФИО отдельно
            v_fio  := TRIM(upper(FM_) || ' ' || upper(NM_) || ' ' || CASE WHEN REC.NO_FT = 1 THEN NULL ELSE upper(FT_) END);
            -- текст без ФИО (BANK_ACCOUNT_PERSONAL + текст назначения)
            v_text := TRIM(SUBSTR(F70_PAY_ASSIGN_, 1, LENGTH(F70_PAY_ASSIGN_) - LENGTH(v_fio) - 1));

            if LENGTH(v_text) > 128 then
              -- текст без ФИО тоже не влезает — обрезаем до 128, остаток + ФИО в F72
              F72_ := SUBSTR('/NZP/' || SUBSTR(v_text, 129) || ' ' || v_fio,1, 68);
              F70_PAY_ASSIGN_ := SUBSTR(v_text, 1, 128);
            else
              -- текст влезает — ФИО целиком уходит в F72
              F70_PAY_ASSIGN_ := v_text;
              F72_ := SUBSTR('/NZP/' || v_fio, 1, 68);
            end if;
          end;
        elsif REC.G_COUNTRY_CODE != 'BLR' and LENGTH(F70_PAY_ASSIGN_) > 130 then
          F72_ := SUBSTR('/NZP/' || SUBSTR(F70_PAY_ASSIGN_, 131), 1, 68);
          F70_PAY_ASSIGN_ := SUBSTR(F70_PAY_ASSIGN_, 1, 130);
        else
          F72_ := NULL;
        end if;
      else
       F72_ := NULL;
      end if;


      insert into O_MT103(O_MT103,
          WORKING_DATE, ID_USR, F20, FCURR_CODE, FCURR_DATE, FSUMM, FGUARANTOR_ACCOUNT, FGUARANTOR_IDN, FGUARANTOR_IRS, FGUARANTOR_SECO,
          FGUARANTOR_NAME, FGUARANTOR_ADDRESS, FGUARANTOR_COUNTRY, FGUARANTOR_CHIEF, FGUARANTOR_MAIN_BK, F52B_GUARANTOR_BANK_MFO,
          F56C_INTERMED_BANK_MFO,F56C_INTERMED_ACCOUNT, F56C_INTERMED_NAME, F56C_INTERMED_ADDRESS, F56C_INTERMED_COUNTRY,
          F57C_BENEF_BANK_MFO, F57C_BENEF_ACCOUNT, F57C_BENEF_NAME,F57C_BENEF_ADDRESS, F57C_BENEF_COUNTRY, F57C_BENEF_COUNTRYCODE,
          F50K_PAYER_ACCOUNT, F50K_PAYER_IDN, F50K_PAYER_NAME,F59_BENEF_ACCOUNT,F59_BENEF_NAME,F59_BENEF_IDN,F59_BENEF_KPP,F59_BENEF_ECON_SECT,F59_BENEF_IRS,F59_BENEF_SECO,F59_BENEF_ADDRESS, F59_BENEF_COUNTRY, F59_BENEF_COUNTRYCODE,
          F70_KNP, F70_DOC_DATE, F70_CONT, F70_CONTDD, F70_INV, F70_VOPER, F70_PAY_ASSIGN,
          P_CLAIM_PAY_OUT,
          F71A, F71B,
          SYS_DATE, F72, CURRENCY_COURSE, KZT_SUM)
      values(MAIN.SEQ_O_MT103.NEXTVAL, CONNECTION_PARAM.IDOPERDAY, CONNECTION_PARAM.IDUSER, REC.F20, REC.CODE, REC.F32A_CURR_DATE, REC.FSUMM, REC.F50_GUARANTOR_ACCOUNT,
          REC.F50_GUARANTOR_RNN, REC.FGUARANTOR_IRS, REC.FGUARANTOR_SECO, REC.F50_GUARANTOR_NAME, REC.FGUARANTOR_ADDRESS, REC.FGUARANTOR_COUNTRY, REC.F50_GUARANTOR_CHIEF,
          REC.F50_GUARANTOR_MAIN_BK, REC.F52B_GUARANTOR_BANK_MFO,
          REC.F56C_INTERMED_BANK_MFO, REC.F56C_INTERMED_ACCOUNT, REC.F56C_INTERMED_NAME, REC.F56C_INTERMED_ADDRESS,REC.F56C_INTERMED_COUNTRY,
          REC.F57C_BENEF_BANK_MFO, REC.F57C_BENEF_ACCOUNT, REC.F57C_BENEF_NAME, REC.BANK_ADDR, REC.F57C_BENEF_COUNTRY, REC.F57C_BENEF_COUNTRYCODE,
          REC.F50K_PAYER_ACCOUNT, REC.F50K_PAYER_IDN, REC.F50K_PAYER_NAME,
          REC.F59_BENEF_ACCOUNT,NVL(F59_BENEF_NAME_, REC.F59_BENEF_NAME),REC.F59_BENEF_IDN,REC.F59_BENEF_KPP,REC.F59_BENEF_ECON_SECT,REC.F59_BENEF_IRS,REC.F59_BENEF_SECO,REC.ADDRESS, REC.F59_BENEF_COUNTRY, REC.F59_BENEF_COUNTRYCODE,
          REC.F70_KNP, REC.F70_DOC_DATE,REC.F70_CONT, REC.F70_CONTDD, REC.F70_INV, REC.F70_VOPER, NVL(F70_PAY_ASSIGN_, REC.F70_PAY_ASSIGN),
          REC.P_CLAIM_PAY_OUT,
          REC.F71A, REC.F71B,
          SYSDATE, F72_, REC.CURRENCY_COURSE, REC.KZT_SUM)
      returning O_MT103 into O_MT103_;

      vlcLogStep := vlcLogStep||O_MT103_||';';
      insert into d__lt_mt103 (id,o_mt,O_MT103)
      values (MAIN.SEQ_O_MT103.NEXTVAL,REC.O_MT,O_MT103_);

      insert into O_MT103_HIS(O_MT103_HIS, O_MT103, WORKING_DATE, ID_USR, F20, FCURR_CODE, FCURR_DATE, FSUMM, FGUARANTOR_ACCOUNT, FGUARANTOR_IDN, FGUARANTOR_IRS, FGUARANTOR_SECO,
                          FGUARANTOR_NAME, FGUARANTOR_ADDRESS, FGUARANTOR_COUNTRY, FGUARANTOR_CHIEF, FGUARANTOR_MAIN_BK, F52B_GUARANTOR_BANK_MFO, F56C_INTERMED_BANK_MFO,
                          F56C_INTERMED_ACCOUNT, F56C_INTERMED_NAME, F56C_INTERMED_ADDRESS, F56C_INTERMED_COUNTRY, F57C_BENEF_BANK_MFO, F57C_BENEF_ACCOUNT, F57C_BENEF_NAME,
                          F57C_BENEF_ADDRESS, F57C_BENEF_COUNTRY, F57C_BENEF_COUNTRYCODE, F50K_PAYER_ACCOUNT, F50K_PAYER_IDN, F50K_PAYER_NAME, F59_BENEF_ACCOUNT, F59_BENEF_NAME,
                          F59_BENEF_IDN, F59_BENEF_KPP, F59_BENEF_ECON_SECT, F59_BENEF_IRS, F59_BENEF_SECO, F59_BENEF_ADDRESS, F59_BENEF_COUNTRY, F59_BENEF_COUNTRYCODE,
                          F70_KNP, F70_DOC_DATE, F70_CONT, F70_CONTDD, F70_INV, F70_VOPER, F70_PAY_ASSIGN, P_CLAIM_PAY_OUT, F71A, F71B, FDATE, FCUR_DATE, FDOC_DATE, FILE_BODY, SYS_DATE, F72 , CURRENCY_COURSE, KZT_SUM)
      values(MAIN.SEQ_O_MT103_HIS.NEXTVAL, O_MT103_, CONNECTION_PARAM.IDOPERDAY, CONNECTION_PARAM.IDUSER, REC.F20, REC.CODE, REC.F32A_CURR_DATE, REC.FSUMM, REC.F50_GUARANTOR_ACCOUNT,
          REC.F50_GUARANTOR_RNN, REC.FGUARANTOR_IRS, REC.FGUARANTOR_SECO, REC.F50_GUARANTOR_NAME, REC.FGUARANTOR_ADDRESS, REC.FGUARANTOR_COUNTRY, REC.F50_GUARANTOR_CHIEF,
          REC.F50_GUARANTOR_MAIN_BK, REC.F52B_GUARANTOR_BANK_MFO, REC.F56C_INTERMED_BANK_MFO, REC.F56C_INTERMED_ACCOUNT, REC.F56C_INTERMED_NAME, REC.F56C_INTERMED_ADDRESS,
          REC.F56C_INTERMED_COUNTRY, REC.F57C_BENEF_BANK_MFO, REC.F57C_BENEF_ACCOUNT, REC.F57C_BENEF_NAME, REC.F57C_BENEF_ADDRESS, REC.F57C_BENEF_COUNTRY, REC.F57C_BENEF_COUNTRYCODE,
          REC.F50K_PAYER_ACCOUNT, REC.F50K_PAYER_IDN, REC.F50K_PAYER_NAME, REC.F59_BENEF_ACCOUNT, NVL(F59_BENEF_NAME_, REC.F59_BENEF_NAME), REC.F59_BENEF_IDN, REC.F59_BENEF_KPP, REC.F59_BENEF_ECON_SECT,
          REC.F59_BENEF_IRS, REC.F59_BENEF_SECO, REC.F59_BENEF_ADDRESS, REC.F59_BENEF_COUNTRY, REC.F59_BENEF_COUNTRYCODE, REC.F70_KNP, REC.F70_DOC_DATE,
          REC.F70_CONT, REC.F70_CONTDD, REC.F70_INV, REC.F70_VOPER, NVL(F70_PAY_ASSIGN_, REC.F70_PAY_ASSIGN), REC.P_CLAIM_PAY_OUT, REC.F71A, REC.F71B, vldSEND_DATE, vldFCurr_Date, DOC_DATE_, NULL, SYSDATE, F72_ , REC.CURRENCY_COURSE, REC.KZT_SUM);
    end;
  end loop;

  vlcLogs     := vlcLogs||chr(10)||(to_char(systimestamp,'hh24:mi:ss.FF')||' vlcTmp['||vlcTmp||'] O_MT103_['||vlcLogStep||']');

  update main.o_mt103                           --- На тот случай если расчет и корректировка уже проводилась за эту дату
  set FSUMM=nvl(Round(KZT_SUM/nvl(CURRENCY_COURSE,1),2),0)
  where fcurr_date=vldFCurr_Date and nvl(KZT_SUM,0)<>0;       --- Дата валютирования

  for vlrRec IN (select fcurr_code                                           --- Корректируем суммы в иностранной валюте по ошибке округления
                     , round(sum(kzt_sum)/currency_course,2)-sum(round(kzt_sum/currency_course,2)) as Сorrect --- Сумма корректировки
                 from main.O_MT103 where fcurr_date=vldFCurr_Date
                 group by fcurr_code,currency_course) loop

    vlcLogs     := vlcLogs||chr(10)||(to_char(systimestamp,'hh24:mi:ss.FF')||' Сorrect['||vlrRec.Сorrect||'] fcurr_code['||vlrRec.fcurr_code||'] fcurr_date['||NVL(FCUR_DATE_, vldFDoc_DATE)||'] ');

    if vlrRec.Сorrect>0 then
       update O_MT103 SET FSUMM=FSUMM+0.01
       where O_MT103 IN (select *
                         from (select o.O_MT103
                               from O_MT103 o
                               where o.fcurr_code=vlrRec.fcurr_code
                                 and fcurr_date=vldFCurr_Date
                               order by FSUMM desc
                               )
                         where ROWNUM <= vlrRec.Сorrect*100);  -- выбираем для апдейта количество строк равное разнице между суммама,
                                                           -- при этом берем тех, у кого корректировка вызовет минимальную ошибку округления
    elsif vlrRec.Сorrect<0 then
       update O_MT103 SET FSUMM=FSUMM-0.01
       where O_MT103 IN (select *
                         from (select o.O_MT103
                               from O_MT103 o
                               where o.fcurr_code=vlrRec.fcurr_code
                                 and fcurr_date=vldFCurr_Date
                               order by FSUMM desc
                               )
                         where ROWNUM <= abs(vlrRec.Сorrect*100));  -- выбираем для апдейта количество строк равное разнице между суммама,

    end if;
  end loop;
  commit;

  ----------------------------------------------------------- ФОРМИРУЕМ ФАЙЛ CLOB ---------------------------------------------------------------------------------------------------
  MAIN.MT.GET_OUR_CRYPTO_CODE(CODE_    => SENDER_,
                              NAME_    => SENDER_NAME_,
                              ERR_CODE => ERR_CODE_,
                              ERR_MSG  => ERR_MSG_);

  if ERR_CODE_ <> 0 then
    ERR_MSG  := PROCNAME || ' 020 --> ' || ERR_MSG_;
    raise TYPES.E_FORCE_EXIT;
  end if;

  if PARAMS.GET_SYSTEM_SETUP_PARAM('IS_TRANS_ENPF') = 1 then
    RECEIVER_      := PARAMS.GET_SYSTEM_SETUP_PARAM('CRYPTO_CODE_KCMR');
  else
    RECEIVER_      := PARAMS.GET_SYSTEM_SETUP_PARAM('CRYPTO_CODE_FOR_SKP');
  end if;

  for EAES IN (select --NVL(decode(PE.G_COUNTRY,2, null ,CP.P_CLAIM_PAY_OUT), max(CP.P_CLAIM_PAY_OUT))
                      max(CP.P_CLAIM_PAY_OUT) P_CLAIM_PAY_OUT
                from MAIN.P_CLAIM_PAY_OUT CP,
                     (select CP.P_CLAIM_PAY_OUT
                        from MAIN.P_OPR PO
                            ,MAIN.P_G_OPRKND K
                            ,MAIN.P_LT_OPR_CLAIM LT
                            ,MAIN.P_CLAIM_PAY_OUT CP
                       where PO.WORKING_DATE = WORKING_DATE_
                         and K.P_G_GROUP_OPRKND = 9
                         and PO.P_G_OPRKND = K.P_G_OPRKND
                         and LT.P_OPR = PO.P_OPR
                         and CP.P_CLAIM_PAY_OUT = LT.P_CLAIM_PAY_OUT
                         and CP.BANK_IS_FOREIGN = 1) T,
                     MAIN.P_PAYMENT_INFO    PI,
                     MAIN.O_MT              M,
                     MAIN.G_JUR_PERSON_EAES PE,
                     ADM.T_INT_TABLE1# IT1
               where CP.BANK_IS_FOREIGN = 1
                 and CP.P_CLAIM_PAY_OUT = T.P_CLAIM_PAY_OUT
                 and CP.P_CLAIM_PAY_OUT = PI.P_CLAIM_PAY_OUT
                 and PI.O_MT = M.O_MT
                 and M.F32A_CURR_DATE = vldFCurr_Date
                 and PE.G_JUR_PERSON_EAES = CP.BANK_G_JUR_PERSON
                 and PE.G_JUR_PERSON_EAES = IT1.ID
                 and PE.G_COUNTRY in (RUSSIA,BELARUSSIA,KYRGYZSTAN)
               --group by PE.G_JUR_PERSON_EAES,
               --         PE.G_COUNTRY,
               --         decode(PE.G_COUNTRY,2,NULL,CP.P_CLAIM_PAY_OUT)
               ) loop
    select COUNT(1)
    into CNT_
    from ADM.T_INT_TABLE# IT
    where IT.ID = nvl(EAES.P_CLAIM_PAY_OUT,0);
    if CNT_ = 0 then
      insert into ADM.T_INT_TABLE# (ID) values(nvl(EAES.P_CLAIM_PAY_OUT,0));
     --DELETE O_MT103 where P_CLAIM_PAY_OUT = EAES.P_CLAIM_PAY_OUT;
    end if;
  end loop;
  for REC IN (select '{4:'||CrLf||
                     ':20:'||O.F20||CrLf||
                     --23.08.2022: Миреев А. Заявка №323
                     --если в заявлении указан комп орган Россия, то поле :26Т: появляется, иначе исчезает
                     decode(pe.g_jur_person_eaes,
                            null,
                            null,
                            decode(pe.g_country,
                                         RUSSIA, ':26Т:'||'S08'||CrLf,
                                         null)
                            )||
                     ':32A:'||To_Char(NVL(vldFCurr_Date, vldSEND_DATE), 'YYMMDD')||O.FCURR_CODE||To_Char(O.FSUMM)||CrLf||
                     ':50:/D/'||O.FGUARANTOR_ACCOUNT||CrLf||
                     '/IDN/'||O.Fguarantor_Idn||CrLf||
                     '/IRS/'||O.fguarantor_irs||CrLf||
                     '/SECO/'||O.fguarantor_seco||CrLf||
                     '/NAME/'||upper(O.fguarantor_name)||CrLf||
                     '/ADDRESS/'||upper(O.fguarantor_address)||CrLf||
                     '/COUNTRY/'||upper(O.fguarantor_country)||CrLf||
                     '/CHIEF/'||O.fguarantor_chief||CrLf||
                     '/MAINBK/'||O.fguarantor_main_bk||CrLf||
                     ':52B:'||O.f52b_guarantor_bank_mfo||CrLf||
                     ':56C:'||O.f56c_intermed_bank_mfo||CrLf||
                     '/NAME/'||O.f56c_intermed_name||CrLf||
                     '/ADDRESS/'||O.f56c_intermed_address||CrLf||
                     '/COUNTRY/'||O.f56c_intermed_country||CrLf||
                     ':57C:'||decode(pe.g_jur_person_eaes,null, O.f57c_benef_bank_mfo||'/'||O.f57c_benef_account,
                                                     decode(pe.g_country,
                                                                  RUSSIA,     jp.bik||'/'||pe.acc_1,
                                                                  BELARUSSIA, jp.bik,
                                                                              jp.bik
                                                             ))||CrLf||
                     '/NAME/'||O.f57c_benef_name||decode(O.FCURR_CODE,'RUB','',decode(O.f57c_benef_bank_mfo,null,'/Adrline/'||o.f57c_benef_address,''))||CrLf||
                     '/ADDRESS/'||CrLf||
--                     '/COUNTRY/'||O.f57c_benef_country||CrLf||                         --- 07.02.2025 OlzhasT добавил вызов функцию для вывода наименование страны на латинице
                     '/COUNTRY/'||decode(O.f57c_benef_countrycode,'RU',O.f57c_benef_country,f__country_nameen(O.f57c_benef_countrycode))||CrLf||
                     '/COUNTRYCODE/'||O.f57c_benef_countrycode||CrLf||
                     ':59:'||O.f59_benef_account||CrLf||
                     '/IDN/'||O.f59_benef_idn||CrLf||
                     '/IRS/'||O.f59_benef_irs||CrLf||
                     '/SECO/'||O.f59_benef_seco||CrLf||
                     --- '/NAME/'||O.f59_benef_name||'/Adrline/'||o.f59_benef_address||CrLf||
                     '/NAME/'||O.f59_benef_name||CrLf||
                     '/ADDRESS/'||CrLf||
--                     '/COUNTRY/'||O.f59_benef_country||CrLf|| 07.02.2025 OlzhasT добавил вызов функцию для вывода наименование страны на латинице
                     '/COUNTRY/'||decode(O.FCURR_CODE,'RUB',O.f59_benef_country,decode(O.f59_benef_countrycode,'RU',O.f59_benef_country,f__country_nameen(O.f59_benef_countrycode)))||CrLf||
                     '/COUNTRYCODE/'||O.f59_benef_countrycode||CrLf||
                     ':70:/KNP/'||O.f70_knp||CrLf||
                     '/DATE/'||O.f70_doc_date||CrLf||
                     '/VOPER/'||O.f70_voper||CrLf||
                     '/ASSIGN/'||substr(O.f70_pay_assign,1,140)||CrLf||
                     ':71A:'||O.f71a||CrLf||
                     ':71B:'||O.f71b||CrLf||
                     ':72:'||O.F72||
                         decode(length(substr(O.f70_pay_assign,141,length(O.f70_pay_assign))),0,''||substr(O.f70_pay_assign,141,length(O.f70_pay_assign)))||CrLf||
                     --23.08.2022: Миреев А. Заявка №323
                     --если в заявлении указан комп орган Россия, то поле :77В: появляется, иначе исчезает
                     decode(pe.g_jur_person_eaes,
                                            null, null,
                                            decode(pe.g_country,
                                                         RUSSIA, ':77В:'||'/N4/'||pe.kbk||'/N5/'||pe.oktmo||CrLf,
                                                         null
                                   )
                            )||
                     '-}' AS MAIN_BODY,
                     O.O_MT103
      from ADM.T_INT_TABLE#  T,
           MAIN.O_MT103      O,
           p_claim_pay_out   po,
           g_jur_person_eaes pe, --23.08.2022: Миреев А. Заявка №323
           g_jur_person      jp  --23.08.2022: Миреев А. Заявка №323
     where T.ID = O.P_CLAIM_PAY_OUT
       and po.p_claim_pay_out = t.id
       and pe.g_jur_person_eaes(+) = po.bank_g_jur_person --23.08.2022: Миреев А. Заявка №323
       and jp.g_jur_person(+) = po.bank_g_jur_person      --23.08.2022: Миреев А. Заявка №323
       and o.fcurr_date>vldFCurr_Date-10
     order by O.O_MT103
     ) loop
    MAIN.MT.GET_MT_HEADERS(SENDER_      => SENDER_,  -- Получить заголовок исходящего сообщения
                           RECEIVER_    => RECEIVER_,
                           MT_TYPE_     => '103',
                           MAIN_HEADER_ => MAIN_HEADER_,
                           APP_HEADER_  => APP_HEADER_);

    BODY_ := MAIN_HEADER_||CrLf|| APP_HEADER_||CrLf|| REC.MAIN_BODY;


   --23.08.2022: Миреев А. Заявка №323
    if CBODY_ IS null then
      CBODY_ := BODY_;
    else
      CBODY_ := CBODY_ ||CrLf|| BODY_;
    end if;


    update MAIN.O_MT103_HIS M  -- 20-02-2020: МАМЕТОВ СЕРИК Добавил возможность сохранения истории по каждому заявлению на перевод в ин.валюте
       SET M.FILE_BODY = REC.MAIN_BODY
    where M.O_MT103 = REC.O_MT103;
  end loop;


  if CBODY_ IS null then  --05.09.2022: Миреев А. Если не записать хоть что нибудь, то в делфи вылетае ошибка при выгрузке.
    CBODY_ := 'MT103 body is empty!';
  end if;


  commit;
  main.pp_Save_ERROR('P_BUILD_OUTGOING_MT103[Ok] USERENV['||nvl(upper(SYS_CONTEXT('USERENV','OS_USER')),'**')||'] vlcLogs['||Trim(vlcLogs)||'] ['||SUBSTR(SQLERRM,1,1000)||']');
exception
  when TYPES.E_FORCE_EXIT then
    main.pp_Save_ERROR('P_BUILD_OUTGOING_MT103[TYPES.E_FORCE_EXIT] ['||nvl(Dbms_Utility.FORMAT_ERROR_BACKTRACE,'-=NULL=-') ||'] ['||DBMS_UTILITY.FORMAT_CALL_STACK||'] USERENV['||nvl(upper(SYS_CONTEXT('USERENV','OS_USER')),'**')||'] vlcLogs['||Trim(vlcLogs)||'] ['||SUBSTR(SQLERRM,1,1000)||']');
    rollback;
  when others then
    ERR_CODE := SQLCODE;
    ERR_MSG  := PROCNAME || ' 00' || ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, SQLERRM);
    rollback;
    main.pp_Save_ERROR('P_BUILD_OUTGOING_MT103['||nvl(Dbms_Utility.FORMAT_ERROR_BACKTRACE,'-=NULL=-') ||'] ['||DBMS_UTILITY.FORMAT_CALL_STACK||'] USERENV['||nvl(upper(SYS_CONTEXT('USERENV','OS_USER')),'**')||'] vlcLogs['||Trim(vlcLogs)||'] ['||SUBSTR(SQLERRM,1,1000)||']');
END P_BUILD_OUTGOING_MT103;
/
