CREATE OR REPLACE PROCEDURE p_read_opr_printpayoutoverseas(
  DATE_       IN  DATE,
  OPER_DATE_  IN  DATE,
  MODE_       IN  INTEGER,
  DATE_CLAIM_ OUT DATE,
  CUR         OUT ADM.TYPES.TCUR,
  ERR_CODE    OUT ADM.TYPES.TERR_CODE,
  ERR_MSG     OUT ADM.TYPES.TERR_MSG
) IS
  ----------------------------------------------------------------------------------------------
  -- Выборка данных, режим "ОПЕРАЦИИ -> ВЫПЛАТЫ -> ПЕЧАТЬ ПЛАТЕЖЕЙ  С ВИДОМ ВЫПЛАТЫ "ВЫПЛАТА ЗА ГРАНИЦУ""
  ----------------------------------------------------------------------------------------------
  -- История изменений:
  -- Дата        Кто             Comments  где изменялось
  ----------------------------------------------------------------------------------------------
  -- 06/06/2013  СЕРИК
  -- 08.04.2022  Бычков М.       Избавляемся от мультипликации записей о двух и более выплатах с одного ИПС
  -- 01.09.2022  Миреев А.       Модернизация ИС ИАИС-2 ПУПН. Заявка №323. 'Выплаты в компетентные органы (КО) стран ЕАЭС в иностранной валюте. Реализовать: отдельное КНП в распоряжении
  --                             на конвертацию (МТ100) и на перевод денег (МТ103), коррект
  --                             в MODE_ = 0 Добавил определение ЕАЭС
  -- 08.12.2022  Y.Syunyakova    добавила  P_G_GROUP_OPRKND 10 и and sys_date>=DATE_CLAIM_ для O_MT103 (что б не показывал записи по выплате) операции Возмещение ИПН для выехавших на ПМЖ (справка 27)
  -- 07.02.2024  AnvarT          Чуть оптимизировал и причесал
  -- 22.05.2025  AnvarT          Еще раз оптимизировал и причесал
  ------------------------------------------------------------------------------------------------------------
  PROCNAME      CONSTANT ADM.TYPES.TPROC_NAME := 'PREADOPRPRINTPAYOUTOVERSEAS';
  WORKING_DATE_ WORKING_DATE.WORKING_DATE%TYPE;

  RUSSIA CONSTANT NUMBER     := 2;
  BELARUSSIA CONSTANT NUMBER := 34;
  KYRGYZSTAN CONSTANT NUMBER := 108;
  vlcLogs                             clob;
begin
  ERR_CODE := 0;
  ERR_MSG := ' ';
  vlcLogs     := vlcLogs||chr(10)||(to_char(systimestamp,'hh24:mi:ss.FF')||' Start'
                        ||chr(10)||' DATE_['||DATE_||']'
                        ||chr(10)||' MODE_['||MODE_||']'
                        ||chr(10)||'OPER_DATE_['||OPER_DATE_||']'
                        );
  WORKING_DATE_ := WORKING_DATE_PACK.GET_WORKING_DATE_BY_WORK_DATE(WORK_DATE_ => DATE_);
  DATE_CLAIM_   := WORKING_DATE_PACK.GET_WORKS_DAY_BY_COUNT(CONNECTION_PARAM.dOper, 2);

  if MODE_ = 0 then
    begin
      OPEN CUR FOR
        select CP.P_CLAIM_PAY_OUT,
               To_Char(CP.P_CLAIM_PAY_OUT) P_CLAIM_PAY_OUT_STR,
               CP.P_CONTRACT,
               CP.FM,
               CP.NM,
               CP.FT,
               To_Char(CP.DT) DT,
               NVL(NP.IDN, CP.RNN) RNN,
               DATE_ DATE_PAY_FACT, -- PI.DATE_PAY_FACT, -- 08.04.2022
               CP.REFERENCE,
               CP.DATE_RECEPTION,
               CP.BANK_BIK,
               CP.BANK_RNN,
               CP.BANK_ACCOUNT,
               CP.BANK_ACCOUNT_PERSONAL,
               CP.BANK_BRANCH_NAME,
               CP.BANK_BRANCH_CODE,
               CP.BANK_FOREIGN_KPP,
               CP.BANK_FOREIGN_ACCOUNT,
               CP.BANK_NAME,
               CP.G_RESIDENTS,
               PO.SUMMA SUMMA,
               CP.G_CURRENCY,
               DATE_CLAIM_,
               P_GET_PRINTPAYOUTOVERSEAS_XML(CP.P_CLAIM_PAY_OUT, 1) TIME_CREATE_XML_TRANSFER,
               P_GET_PRINTPAYOUTOVERSEAS_XML(CP.P_CLAIM_PAY_OUT, 2) TIME_CREATE_XML_RECONV,
               DECODE((select COUNT(1)
                       from MAIN.O_MT103 M
                       where M.P_CLAIM_PAY_OUT = CP.P_CLAIM_PAY_OUT ), 0, 0, 1) O_MT103,
               '0' G_JUR_PERSON_EAES
          from MAIN.P_OPR PO
               join MAIN.P_G_OPRKND K on PO.P_G_OPRKND = K.P_G_OPRKND
               join MAIN.P_LT_OPR_CLAIM LT on PO.P_OPR = LT.P_OPR
               join MAIN.P_CLAIM_PAY_OUT CP on LT.P_CLAIM_PAY_OUT = CP.P_CLAIM_PAY_OUT
               join MAIN.P_G_PAY_OUT_SUB_TYPE PT on PT.P_G_PAY_OUT_SUB_TYPE=CP.P_G_PAY_OUT_SUB_TYPE
               -- MAIN.WORKING_DATE W, --P_PAYMENT_INFO PI, -- 08.04.2022
               join MAIN.P_CONTRACT PC on PC.P_CONTRACT=CP.P_CONTRACT
               join MAIN.G_NAT_PERSON NP on NP.G_PERSON=PC.G_PERSON_RECIPIENT
               --01.09.2022: Миреев А.
               left join MAIN.G_JUR_PERSON_EAES PE on PE.G_JUR_PERSON_EAES=CP.BANK_G_JUR_PERSON
               left join MAIN.G_JUR_PERSON JP on PE.G_JUR_PERSON_EAES=JP.G_JUR_PERSON
               left join MAIN.O_MT103 MT103 on CP.P_CLAIM_PAY_OUT=MT103.P_CLAIM_PAY_OUT and MT103.WORKING_DATE=PO.WORKING_DATE
         where PO.WORKING_DATE = WORKING_DATE_
           and K.P_G_GROUP_OPRKND   in (9,10)
           and CP.BANK_IS_FOREIGN = 1
           -- and CP.P_CLAIM_PAY_OUT = PI.P_CLAIM_PAY_OUT -- 08.04.2022
           --01.09.2022: Миреев А.
           and NOT EXISTS (select 1 from main.G_JUR_PERSON_EAES PE where PE.G_JUR_PERSON_EAES = CP.BANK_G_JUR_PERSON)
         /*
          from MAIN.P_OPR PO,
               MAIN.P_G_OPRKND K,
               MAIN.P_LT_OPR_CLAIM LT,
               MAIN.P_CLAIM_PAY_OUT CP,
               MAIN.P_G_PAY_OUT_SUB_TYPE PT,
               -- MAIN.WORKING_DATE W, --P_PAYMENT_INFO PI, -- 08.04.2022
               MAIN.P_CONTRACT PC,
               MAIN.G_NAT_PERSON NP,
               --01.09.2022: Миреев А.
               MAIN.G_JUR_PERSON JP,
               MAIN.G_JUR_PERSON_EAES PE,
               MAIN.O_MT103 MT103
         where -- W.WORKING_DATE = PO.WORKING_DATE --PI.WORKING_DATE = WORKING_DATE_ -- 08.04.2022
             --по задаче в Битриксе №188778 дописал условие ниже. Связанно с тем что могут быть операции выплат за границу даже с видом заявления на выплату 402 -
             --График/Частичная выплата в связи с достижением пенсионного возраста. А у него другое условие выплаты и операции в таблице P_LT_OPR_CLAIM будут сидеть несколько.
             --Поэтому выюорка будет возвращать две и более записи по одному и тому же заявлению. Ранее выплат по графику с видом 402 не было. Серик 24-02-2017
               PO.WORKING_DATE = WORKING_DATE_
           and PO.P_G_OPRKND = K.P_G_OPRKND
           and K.P_G_GROUP_OPRKND   in (9,10)
           and PO.P_OPR = LT.P_OPR
           and LT.P_CLAIM_PAY_OUT = CP.P_CLAIM_PAY_OUT
           and CP.P_G_PAY_OUT_SUB_TYPE = PT.P_G_PAY_OUT_SUB_TYPE
           and CP.BANK_IS_FOREIGN = 1
           -- and CP.P_CLAIM_PAY_OUT = PI.P_CLAIM_PAY_OUT -- 08.04.2022
           and CP.P_CONTRACT = PC.P_CONTRACT
           and PC.G_PERSON_RECIPIENT = NP.G_PERSON

           --01.09.2022: Миреев А.
           and PE.G_JUR_PERSON_EAES(+) = CP.BANK_G_JUR_PERSON
           and JP.G_JUR_PERSON(+) = PE.G_JUR_PERSON_EAES
           and MT103.P_CLAIM_PAY_OUT(+) = CP.P_CLAIM_PAY_OUT
           and NOT EXISTS (select 1 from G_JUR_PERSON_EAES PE where PE.G_JUR_PERSON_EAES = CP.BANK_G_JUR_PERSON)
         */

        union all
        --01.09.2022: Миреев А.
        select
               MAX(DECODE(PE.G_COUNTRY,
                                     RUSSIA,     0,
                                     BELARUSSIA, 0,
                                     KYRGYZSTAN, 0,
                                     CP.P_CLAIM_PAY_OUT)) P_CLAIM_PAY_OUT,--MAX(CP.P_CLAIM_PAY_OUT) P_CLAIM_PAY_OUT,
               MAX(DECODE(PE.G_COUNTRY,
                                     RUSSIA,     '0',
                                     BELARUSSIA, '0',
                                     KYRGYZSTAN, '0',
                                     To_Char(CP.P_CLAIM_PAY_OUT))) P_CLAIM_PAY_OUT_STR,--To_Char(MAX(CP.P_CLAIM_PAY_OUT)) P_CLAIM_PAY_OUT_STR,
               MAX(DECODE(PE.G_COUNTRY,
                                     RUSSIA, 0,
                                     BELARUSSIA, 0,
                                     KYRGYZSTAN, 0,
                                     CP.P_CONTRACT)) P_CONTRACT,--MAX(CP.P_CONTRACT) P_CONTRACT,
               DECODE(PE.G_COUNTRY,
                                 RUSSIA, JP.SHORT_NAME,
                                 BELARUSSIA, JP.SHORT_NAME,
                                 KYRGYZSTAN, JP.SHORT_NAME,
                                 CP.FM) FM,
               MAX(DECODE(PE.G_COUNTRY,
                                     RUSSIA,  NULL,
                                     BELARUSSIA, NULL,
                                     KYRGYZSTAN, NULL,
                                     CP.NM)) NM,
               --CP.NM NM2,
               MAX(DECODE(PE.G_COUNTRY,
                                     RUSSIA,  NULL,
                                     BELARUSSIA, NULL,
                                     KYRGYZSTAN, NULL,
                                     CP.FT)) FT,
               --CP.FT FT2,
               MAX(DECODE(PE.G_COUNTRY,
                                     RUSSIA,  NULL,
                                     BELARUSSIA, NULL,
                                     KYRGYZSTAN, NULL,
                                     To_Char(CP.DT))) DT,
               --CP.DT DT2,
               MAX(DECODE(PE.G_COUNTRY,
                                     RUSSIA,  NULL,
                                     BELARUSSIA, NULL,
                                     KYRGYZSTAN, NULL,
                                     NVL(NP.IDN, CP.RNN))) RNN,
               --NVL(NP.IDN, CP.RNN) RNN2,
               MAX(W.WORK_DATE) DATE_PAY_FACT, -- PI.DATE_PAY_FACT, -- 08.04.2022
               MAX(DECODE(PE.G_COUNTRY,
                                     RUSSIA, '-',
                                     BELARUSSIA, '-',
                                     KYRGYZSTAN, '-',
                                     CP.REFERENCE)) REFERENCE, --MAX(CP.REFERENCE) REFERENCE,
               MAX(DECODE(PE.G_COUNTRY,
                                     RUSSIA, To_Date('31.12.1899'),
                                     BELARUSSIA, To_Date('31.12.1899'),
                                     KYRGYZSTAN, To_Date('31.12.1899'),
                                     CP.DATE_RECEPTION)) DATE_RECEPTION,--MAX(CP.DATE_RECEPTION) DATE_RECEPTION,
               MAX(DECODE(PE.G_COUNTRY,
                                     RUSSIA,  JP.BIK||'/'||PE.ACC_1,
                                     BELARUSSIA, JP.BIK,
                                     KYRGYZSTAN, JP.BIK,
                                     JP.BIK)) BANK_BIK,
               --CP.BANK_BIK BANK_BIK2,
               MAX(DECODE(PE.G_COUNTRY,
                                     RUSSIA, ('ИНН'||JP.RNN||'.'||'КПП'||PE.KPP||'*'||UPPER(PE.BANK_NAME)),--MT103.F59_BENEF_NAME,
                                     BELARUSSIA, (PE.BANK_NAME||', UNP '||JP.RNN),
                                     KYRGYZSTAN, CP.BANK_RNN,
                                     CP.BANK_RNN)) BANK_RNN,
               --CP.BANK_RNN BANK_RNN2,
               MAX(CP.BANK_ACCOUNT) BANK_ACCOUNT,
               MAX(DECODE(PE.G_COUNTRY,
                                     RUSSIA, PE.ACC_2,
                                     BELARUSSIA, PE.ACC_2,
                                     KYRGYZSTAN, PE.ACC_2,
                                     CP.BANK_ACCOUNT_PERSONAL)) BANK_ACCOUNT_PERSONAL,
               --CP.BANK_ACCOUNT_PERSONAL BANK_ACCOUNT_PERSONAL2,

               MAX(CP.BANK_BRANCH_NAME) BANK_BRANCH_NAME,
               MAX(CP.BANK_BRANCH_CODE) BANK_BRANCH_CODE,
               MAX(DECODE(PE.G_COUNTRY,
                                     RUSSIA, PE.KPP,
                                     BELARUSSIA, JP.RNN,
                                     KYRGYZSTAN, JP.RNN,
                                     CP.BANK_FOREIGN_KPP)) BANK_FOREIGN_KPP,
               --CP.BANK_FOREIGN_KPP BANK_FOREIGN_KPP2,
               MAX(CP.BANK_FOREIGN_ACCOUNT) BANK_FOREIGN_ACCOUNT,
               MAX(DECODE(PE.G_COUNTRY,
                                     RUSSIA, JP.NAME_NAT,
                                     BELARUSSIA, JP.NAME_NAT,
                                     KYRGYZSTAN, PE.BANK_NAME,
                                     CP.BANK_NAME)) BANK_NAME,
               --CP.BANK_NAME BANK_NAME2,

               MAX(DECODE(PE.G_COUNTRY,
                                     RUSSIA, -1,
                                     BELARUSSIA, -1,
                                     KYRGYZSTAN, -1,
                                     CP.G_RESIDENTS)) G_RESIDENTS, --MAX(CP.G_RESIDENTS) G_RESIDENTS,
               SUM(DECODE(PE.G_COUNTRY,
                                     RUSSIA, MT103.FSUMM,--To_Char(NVL(MT103.FCURR_DATE, '25.07.2022'), 'YYMMDD')||MT103.FCURR_CODE||To_Char(MT103.FSUMM),
                                     BELARUSSIA, MT103.FSUMM,
                                     KYRGYZSTAN, MT103.FSUMM,
                                     PO.SUMMA)) SUMMA,
               --PO.SUMMA SUMMA2,
               MAX(CP.G_CURRENCY) G_CURRENCY,
               DATE_CLAIM_,
               MAX(P_GET_PRINTPAYOUTOVERSEAS_XML(CP.P_CLAIM_PAY_OUT, 1)) TIME_CREATE_XML_TRANSFER,
               MAX(P_GET_PRINTPAYOUTOVERSEAS_XML(CP.P_CLAIM_PAY_OUT, 2)) TIME_CREATE_XML_RECONV,
               MAX(DECODE((select COUNT(1)
                         from MAIN.O_MT103 M
                        where M.P_CLAIM_PAY_OUT = CP.P_CLAIM_PAY_OUT ), 0, 0, 1)) O_MT103,
               To_Char(MAX(PE.G_JUR_PERSON_EAES)) G_JUR_PERSON_EAES
          from MAIN.P_OPR PO,
               MAIN.P_G_OPRKND K,
               MAIN.P_LT_OPR_CLAIM LT,
               MAIN.P_CLAIM_PAY_OUT CP,
               MAIN.P_G_PAY_OUT_SUB_TYPE PT,
               MAIN.WORKING_DATE W, --P_PAYMENT_INFO PI, -- 08.04.2022
               MAIN.P_CONTRACT PC,
               MAIN.G_NAT_PERSON NP,
               --01.09.2022: Миреев А.
               MAIN.G_JUR_PERSON JP,
               MAIN.G_JUR_PERSON_EAES PE,
               MAIN.O_MT103 MT103
         where W.WORKING_DATE = PO.WORKING_DATE --PI.WORKING_DATE = WORKING_DATE_ -- 08.04.2022
           /*по задаче в Битриксе №188778 дописал условие ниже. Связанно с тем что могут быть операции выплат за границу даже с видом заявления на выплату 402 -
             График/Частичная выплата в связи с достижением пенсионного возраста. А у него другое условие выплаты и операции в таблице P_LT_OPR_CLAIM будут сидеть несколько.
             Поэтому выюорка будет возвращать две и более записи по одному и тому же заявлению. Ранее выплат по графику с видом 402 не было. Серик 24-02-2017*/
           and PO.WORKING_DATE = WORKING_DATE_
           and PO.P_G_OPRKND = K.P_G_OPRKND
           and K.P_G_GROUP_OPRKND in (9,10)
           and PO.P_OPR = LT.P_OPR
           and LT.P_CLAIM_PAY_OUT = CP.P_CLAIM_PAY_OUT
           and CP.P_G_PAY_OUT_SUB_TYPE = PT.P_G_PAY_OUT_SUB_TYPE
           and CP.BANK_IS_FOREIGN = 1
           -- and CP.P_CLAIM_PAY_OUT = PI.P_CLAIM_PAY_OUT -- 08.04.2022
           and CP.P_CONTRACT = PC.P_CONTRACT
           and PC.G_PERSON_RECIPIENT = NP.G_PERSON

           --01.09.2022: Миреев А.
           and PE.G_JUR_PERSON_EAES = CP.BANK_G_JUR_PERSON
           and JP.G_JUR_PERSON = PE.G_JUR_PERSON_EAES
           and MT103.P_CLAIM_PAY_OUT(+) = CP.P_CLAIM_PAY_OUT
           --AND MT103.F70_KNP = '105'
         group by DECODE(PE.G_COUNTRY,
                                 RUSSIA, JP.SHORT_NAME,
                                 BELARUSSIA, JP.SHORT_NAME,
                                 KYRGYZSTAN, JP.SHORT_NAME,
                                 CP.FM),
                  DECODE(PE.G_COUNTRY,
                               RUSSIA,     0,
                               BELARUSSIA, 0,
                               KYRGYZSTAN, 0,
                               CP.P_CLAIM_PAY_OUT)

           ;
    end;
  elsif MODE_ = 2 then  --- Повторные выплаты со счета КЗ
    begin

      OPEN CUR FOR
        select CP.P_CLAIM_PAY_OUT,
               To_Char(CP.P_CLAIM_PAY_OUT) P_CLAIM_PAY_OUT_STR,
               CP.P_CONTRACT,
               CP.FM,
               CP.NM,
               CP.FT,
               CP.DT,
               NVL(NP.IDN, CP.RNN) RNN,
               W.WORK_DATE DATE_PAY_FACT, -- PI.DATE_PAY_FACT, -- 08.04.2022
               CP.REFERENCE,
               CP.DATE_RECEPTION,
               CP.BANK_BIK,
               CP.BANK_RNN,
               CP.BANK_ACCOUNT,
               CP.BANK_ACCOUNT_PERSONAL,
               CP.BANK_BRANCH_NAME,
               CP.BANK_BRANCH_CODE,
               CP.BANK_FOREIGN_KPP,
               CP.BANK_FOREIGN_ACCOUNT,
               CP.BANK_NAME,
               CP.G_RESIDENTS,
               PO.SUMMA,
               CP.G_CURRENCY,
               DATE_CLAIM_,
               P_GET_PRINTPAYOUTOVERSEAS_XML(CP.P_CLAIM_PAY_OUT, 1) TIME_CREATE_XML_TRANSFER,
               P_GET_PRINTPAYOUTOVERSEAS_XML(CP.P_CLAIM_PAY_OUT, 2) TIME_CREATE_XML_RECONV
          from MAIN.P_OPR PO,
               MAIN.P_G_OPRKND K,
               MAIN.P_LT_OPR_CLAIM LT,
               MAIN.P_CLAIM_PAY_OUT CP,
               MAIN.WORKING_DATE W, --P_PAYMENT_INFO PI, -- 08.04.2022
               MAIN.P_CONTRACT PC,
               MAIN.G_NAT_PERSON NP
         where W.WORKING_DATE = PO.WORKING_DATE --PI.WORKING_DATE = WORKING_DATE_ -- 08.04.2022
           and PO.P_G_OPRKND = K.P_G_OPRKND
           and K.P_G_GROUP_OPRKND IN (119, 138)
           and PO.P_OPR = LT.P_OPR
           /*по задаче в Битриксе №188778 дописал условие ниже. Связанно с тем что могут быть операции выплат за границу даже с видом заявления на выплату 402 -
             График/Частичная выплата в связи с достижением пенсионного возраста. А у него другое условие выплаты и операции в таблице P_LT_OPR_CLAIM будут сидеть несколько.
             Поэтому выюорка будет возвращать две и более записи по одному и тому же заявлению. Ранее выплат по графику с видом 402 не было. Серик 24-02-2017*/
           and PO.WORKING_DATE = WORKING_DATE_
           and LT.P_CLAIM_PAY_OUT = CP.P_CLAIM_PAY_OUT
           and CP.BANK_IS_FOREIGN = 1
           -- and CP.P_CLAIM_PAY_OUT = PI.P_CLAIM_PAY_OUT -- 08.04.2022
           and CP.P_CONTRACT = PC.P_CONTRACT
           and PC.G_PERSON_RECIPIENT = NP.G_PERSON;
    end;
  else
    begin
      OPEN CUR FOR
        select T.CODE, DATE_CLAIM_, P_GET_PRINTPAYOUTOVERSEAS_XML(M.O_MT, 3) TIME_CREATE_XML_CONV, To_Char(M.O_MT) O_MT_STR, M.*
        from O_MT M,
             (select M.O_MT,
                     C.CODE
                from MAIN.P_CLAIM_PAY_OUT CP,
                     MAIN.P_G_PAY_OUT_SUB_TYPE PT,
                     MAIN.G_CURRENCY C,
                     MAIN.P_PAYMENT_INFO PI,
                     MAIN.O_MT M
               where CP.P_G_PAY_OUT_SUB_TYPE = PT.P_G_PAY_OUT_SUB_TYPE
                 and CP.G_CURRENCY = C.G_CURRENCY
                 and CP.BANK_IS_FOREIGN = 1
                 and CP.P_CLAIM_PAY_OUT = PI.P_CLAIM_PAY_OUT
                 and PI.O_MT = M.O_MT
                 and M.F32A_CURR_DATE = DATE_
            group by C.CODE, M.O_MT) T
       where M.O_MT = T.O_MT;
    end;
  end if;

exception
  when others then
    ERR_CODE := SQLCODE;
    ERR_MSG  := PROCNAME || ' 00' || ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, SQLERRM);
    rollback;
    main.pp_Save_ERROR('P_READ_OPR_PRINTPAYOUTOVERSEAS['||nvl(Dbms_Utility.FORMAT_ERROR_BACKTRACE,'-=NULL=-') ||'] ['||DBMS_UTILITY.FORMAT_CALL_STACK||'] USERENV['||nvl(Upper(SYS_CONTEXT('USERENV','OS_USER')),'**')||'] vlcLogs['||Trim(vlcLogs)||'] ['||SUBSTR(SQLERRM,1,1000)||']');
    OPEN CUR for select NULL from DUAL;
END P_READ_OPR_PRINTPAYOUTOVERSEAS;
/
