CREATE OR REPLACE PACKAGE PENSION_PACK IS

  -- Author  : ADMINISTRATOR
  -- Created : 06.04.2011 18:20:38
  -- Purpose :
  
-- *****  VARIABLES  ******
   HasRight            Number;
   ErrCode             Number;
   ErrMsg              Varchar2(1024);
   SumTranPrtf         Number;
   SumChargPrtf        Number;
   DateTranPrtf        Date;
   PrtfTranSum         Number;
   PrtfChargSum        Number;
   PrtfTranDate        Date;
   -- Признак что запустили выписку с HTML процедуры: необходимо учесть для того что бы человек мог видеть инвест доход или убыток со знаком + или -
   Is_Html_     Number;
   
   -- 15.06.2018 ТЕМЕКОВ АА переменная, которая будет использоваться для вычисления годовой суммы при создании заявления
   -- если 1 - значит заявление создается через ГК, 0 - обычно
   P_Claim_Is_Created_By_Gk  integer;
   
   -- 17.07.2018 ТЕМЕКОВ АА переменная, которая будет использоваться для вычисления годовой суммы при создании заявления
   P_G_Pay_Out_Type      integer;
   
   -- XX.XX.2023     Тайканов Е.Р.   
   vpiRecursion    integer;

-- *****   READ  *****
/*
    FUNCTION GET_CONTRACT_SUMM_BEGIN_YEAR(
        P_CONTRACT_                        IN NUMBER,
        DATE_                              IN DATE,
        ERR_CODE                          OUT  TYPES.TERR_CODE,
        ERR_MSG                           OUT  TYPES.TERR_MSG
        ) RETURN NUMBER;
*/

-- *****   GET   *****
    FUNCTION GET_CONTRACT_SUMM(
        P_CONTRACT_        IN  P_CONTRACT.P_CONTRACT%TYPE,
    	  ERR_CODE	         OUT TYPES.TERR_CODE,
      	ERR_MSG	           OUT TYPES.TERR_MSG
        ) RETURN NUMBER;

    FUNCTION GET_CONTRACT_SUMM(
        P_CONTRACT_        IN  P_CONTRACT.P_CONTRACT%TYPE
        ) RETURN NUMBER;

   FUNCTION GET_CONTRACT_BALANCE_AMOUNT(
        /*ID договора*/
        P_CONTRACT_    IN  P_CONTRACT.P_CONTRACT%TYPE,
        /*Признак что нам возвращать: 0-сумма в тенге, 1-сумма а УЕ*/
        IS_SUMM_       IN  INTEGER DEFAULT 0
        ) RETURN NUMBER;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ОСТАТКА НА ВСЕХ СЧЕТАХ ДОГОВОРА ЗА ДАТУ
    FUNCTION GET_CONTRACT_SUMM_ON_DATE(
        P_CONTRACT_  IN P_CONTRACT.P_CONTRACT%TYPE,
        DATE_        IN DATE
        ) RETURN NUMBER;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ОСТАТКА НА ВСЕХ СЧЕТАХ ВКЛАДЧИКА ЗА ДАТУ
    FUNCTION GET_G_PERSON_SUMM_ON_DATE(
        G_PERSON_    IN P_CONTRACT.G_PERSON_RECIPIENT%TYPE,
        WORKING_DATE_ IN WORKING_DATE.WORKING_DATE%TYPE
        ) RETURN NUMBER;

    FUNCTION GET_CONTRACT_PRTF_SUMM(
        P_CONTRACT_PORTFOLIO_        IN  P_CONTRACT_PORTFOLIO.P_CONTRACT_PORTFOLIO%TYPE
        ) RETURN NUMBER;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ОСТАТКА НА ВСЕХ СЧЕТАХ ВКЛАДЧИКА ЗА ДАТУ
    FUNCTION GET_G_PERSON_SUMM_SAL_ON_DATE(
        G_PERSON_     IN P_CONTRACT.G_PERSON_RECIPIENT%TYPE,
        WORKING_DATE_ IN WORKING_DATE.WORKING_DATE%TYPE
        ) RETURN NUMBER;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ОСТАТКА НА ПОРТФЕЛЕ ДОГОВОРА, БЕЗ ОБРАБОТКИ ОШИБОК, ДЛЯ ИСПОЛЬЗОВАНИЯ В СЕЛЕКТАХ
    FUNCTION GET_P_CONTRACT_PRTF_SUMM(
        P_CONTRACT_    IN  P_CONTRACT.P_CONTRACT%TYPE,
        P_G_PORTFOLIO_ IN  P_G_PORTFOLIO.P_G_PORTFOLIO%TYPE
        ) RETURN NUMBER;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ИНВЕСТ ДОХОДА ПО ВСЕМ ПОРТФЕЛЯМ ВКЛАДЧИКА.
    -- ИНВЕСТ ДОХОД СЧИТАЕТСЯ ТОЛЬКО ПО КУРСУ НА ОТКРЫТУЮ ОПЕРАЦИОННУЮ ДАТУ
    FUNCTION GET_P_CONTRACT_SUMM_ID(
        P_CONTRACT_    IN  P_CONTRACT.P_CONTRACT%TYPE
        ) RETURN NUMBER;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ОСТАТКА НА ПОРТФЕЛЕ ДОГОВОРА НА ДАТУ, БЕЗ ОБРАБОТКИ ОШИБОК, ДЛЯ ИСПОЛЬЗОВАНИЯ В СЕЛЕКТАХ
    FUNCTION GET_P_CONTRACT_PRTF_SUMM_DATE(
        P_CONTRACT_    IN  P_CONTRACT.P_CONTRACT%TYPE,
        P_G_PORTFOLIO_ IN  P_G_PORTFOLIO.P_G_PORTFOLIO%TYPE,
        DATE_          IN DATE
        ) RETURN NUMBER;

   -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ОСТАТКА НА ПОРТФЕЛЕ ДОГОВОРА НА ДАТУ, БЕЗ ОБРАБОТКИ ОШИБОК, ДЛЯ ИСПОЛЬЗОВАНИЯ В СЕЛЕКТАХ
    FUNCTION GET_P_CONTR_PRTF_SUMM_CU_DATE(
        P_CONTRACT_    IN  P_CONTRACT.P_CONTRACT%TYPE,
        P_G_PORTFOLIO_ IN  P_G_PORTFOLIO.P_G_PORTFOLIO%TYPE,
        DATE_          IN DATE
        ) RETURN NUMBER;

    FUNCTION GET_MIN_PENSION_SUMM(
        DATE_               IN  DATE,
        ERR_CODE           OUT  TYPES.TERR_CODE,
        ERR_MSG            OUT  TYPES.TERR_MSG
        ) RETURN NUMBER;

    FUNCTION GET_MIN_SALARY_SUMM(
        DATE_               IN  DATE,
        ERR_CODE           OUT  TYPES.TERR_CODE,
        ERR_MSG            OUT  TYPES.TERR_MSG
        ) RETURN NUMBER;

    FUNCTION GET_MRP_SUMM(
        DATE_        IN  DATE,
        ERR_CODE     OUT  TYPES.TERR_CODE,
        ERR_MSG      OUT  TYPES.TERR_MSG
        ) RETURN NUMBER;

    FUNCTION GET_WITHDRAW_KOEF(
        AGE_               IN   NUMBER,
        ERR_CODE           OUT  TYPES.TERR_CODE,
        ERR_MSG            OUT  TYPES.TERR_MSG
        ) RETURN NUMBER;
    
    FUNCTION GET_PAYOUT_RATE(
        DATE_               IN  DATE,
        ERR_CODE           OUT  TYPES.TERR_CODE,
        ERR_MSG            OUT  TYPES.TERR_MSG
        ) RETURN NUMBER;
        
    FUNCTION GET_PAYOUT_INDEXING_RATE(
        DATE_               IN  DATE,
        ERR_CODE           OUT  TYPES.TERR_CODE,
        ERR_MSG            OUT  TYPES.TERR_MSG
        ) RETURN NUMBER;
        
    FUNCTION GET_CORRECTIVE_COEFFICIENT(
        AGE_                IN  NUMBER,
        COR_COEF_KND_       IN  NUMBER,
        ERR_CODE           OUT  TYPES.TERR_CODE,
        ERR_MSG            OUT  TYPES.TERR_MSG
        ) RETURN NUMBER;
        
   FUNCTION GET_CORRECTIVE_COEF_OPPV(
        DATE_               IN  DATE,
        ERR_CODE           OUT  TYPES.TERR_CODE,
        ERR_MSG            OUT  TYPES.TERR_MSG
        ) RETURN NUMBER;
    
    FUNCTION GET_DATE_BEGIN_PERIOD(
        DATE_               IN  DATE,
        KOEF_               IN  NUMBER,
        ERR_CODE           OUT  TYPES.TERR_CODE,
        ERR_MSG            OUT  TYPES.TERR_MSG
        ) RETURN DATE;

    FUNCTION GET_DATE_END_PERIOD(
        DATE_               IN  DATE,
        KOEF_               IN  NUMBER,
        ERR_CODE           OUT  TYPES.TERR_CODE,
        ERR_MSG            OUT  TYPES.TERR_MSG
        ) RETURN DATE;

    FUNCTION GET_GRF_PERIOD(
        P_GRF_              IN  NUMBER
        ) RETURN VARCHAR2;

    FUNCTION GET_PERIOD_NUM(
        DATE_              IN  DATE, -- ДАТА, НА КОТОРУЮ НУЖНО ВЫЧИСЛИТЬ НОМЕР ПЕРИОДА
        KOEF_              IN NUMBER -- ПЕРИОДИЧНОСТЬ ВЫПЛАТ, 1-ГОД, 2-ПОЛУГОДИЕ, 4-КВАРТАЛ, 12-МЕСЯЦ
        ) RETURN NUMBER;

    FUNCTION GET_IS_HAVE_KZ(
        G_PERSON_           IN  NUMBER/*,
        ERR_CODE            OUT  TYPES.TERR_CODE,
        ERR_MSG             OUT  TYPES.TERR_MSG*/
        ) RETURN NUMBER;

   /*Функция возвращает ID портфеля, по ID операции, т.е. определяет пренадлежность операции к тому или иному портфелю*/
   FUNCTION GET_PRTF_OWNER_OPR(
        P_OPR_  IN  P_OPR.P_OPR%TYPE
        ) RETURN NUMBER;

   FUNCTION GET_AGE_CONTRACT(
       P_CONTRACT_  IN P_CONTRACT.P_CONTRACT%TYPE,
       DATE_        IN DATE
       )RETURN NUMBER;

   FUNCTION GET_IS_HAVE_PENSION_AGE(
       G_PERSON_  IN G_NAT_PERSON.G_PERSON%TYPE,
       DATE_      IN DATE
       )RETURN NUMBER;

    FUNCTION P_GET_RECIPIENT_SUMM_YEAR
        (
        p_contract_    IN  NUMBER,
        DATE_        IN  DATE,
        SUMM_REMAIN_ IN NUMBER,
        IS_VIP_     IN OUT PLS_INTEGER,
        ERR_CODE    OUT NUMBER,
        ERR_MSG     OUT VARCHAR2,
        P_CLAIM_PAY_OUT_ IN NUMBER DEFAULT NULL,
        IS_VIRTUAL_ IN NUMBER DEFAULT 0 -- ПРИЗНАК, ЧТО В ФУНКИЮ В КАЧЕСТВЕ SUMM_REMAIN_ ПЕРЕДАЕТСЯ ВИРТУАЛЬНЫЙ ОСТАТОК, КОТОРЫЙ БУДЕТ У ВКЛАДЧИКА В БУДУЩИХ ГОДАХ
        ) RETURN NUMBER;

     /*ФУНКЦИЯ ВОЗВРАЩАЕТ ВХОДЯЩИЙ ОСТАТОК ПО СЧЕТУ*/
    FUNCTION GET_ACCOUNT_INPUT
      (
      G_ACCOUNT_ IN INTEGER,
      WD_BEGIN_  IN INTEGER,
      WD_END_    IN INTEGER
      ) RETURN NUMBER;

      /*ФУНКЦИЯ ВОЗВРАЩАЕТ ВХОДЯЩИЙ ОСТАТОК ПО СЧЕТУ УЕ*/
    FUNCTION GET_ACCOUNT_INPUT_CU
      (
      G_ACCOUNT_ IN INTEGER,
      WD_BEGIN_  IN INTEGER,
      WD_END_    IN INTEGER
      ) RETURN NUMBER;

      /*ФУНКЦИЯ ВОЗВРАЩАЕТ ИСХОДЯЩИЙ ОСТАТОК ПО СЧЕТУ*/
    FUNCTION GET_ACCOUNT_OUTPUT
      (
      G_ACCOUNT_ IN INTEGER,
      WD_BEGIN_  IN INTEGER,
      WD_END_    IN INTEGER
      ) RETURN NUMBER;

      /*ФУНКЦИЯ ВОЗВРАЩАЕТ ИСХОДЯЩИЙ ОСТАТОК ПО СЧЕТУ УЕ*/
    FUNCTION GET_ACCOUNT_OUTPUT_CU
      (
      G_ACCOUNT_ IN INTEGER,
      WD_BEGIN_  IN INTEGER,
      WD_END_    IN INTEGER
      ) RETURN NUMBER;

    /*ФУНКЦИЯ ВОЗВРАЩАЕТ ДЕБЕТОВЫЕ ОБОРОТЫ ПО СЧЕТУ*/
    FUNCTION GET_ACCOUNT_TURN_DEBET
      (
      G_ACCOUNT_ IN INTEGER,
      WD_BEGIN_  IN INTEGER,
      WD_END_    IN INTEGER
      ) RETURN NUMBER;

    /*ФУНКЦИЯ ВОЗВРАЩАЕТ КРЕДИТОВЫЕ ОБОРОТЫ ПО СЧЕТУ*/
    FUNCTION GET_ACCOUNT_TURN_CREDIT
      (
      G_ACCOUNT_ IN INTEGER,
      WD_BEGIN_  IN INTEGER,
      WD_END_    IN INTEGER
      ) RETURN NUMBER;

    /*ФУНКЦИЯ ВОЗВРАЩАЕТ ДЕБЕТОВЫЕ ОБОРОТЫ ПО СЧЕТУ УЕ*/
    FUNCTION GET_ACCOUNT_TURN_DEBET_CU
    (
    G_ACCOUNT_ IN INTEGER,
    WD_BEGIN_  IN INTEGER,
    WD_END_    IN INTEGER
    ) RETURN NUMBER;

  /*ФУНКЦИЯ ВОЗВРАЩАЕТ КРЕДИТОВЫЕ ОБОРОТЫ ПО СЧЕТУ УЕ*/
  FUNCTION GET_ACCOUNT_TURN_CREDIT_CU
    (
    G_ACCOUNT_ IN INTEGER,
    WD_BEGIN_  IN INTEGER,
    WD_END_    IN INTEGER
    ) RETURN NUMBER;

  /*ФУНКЦИЯ ВОЗВРАЩАЕТ СУММУ СПИСАНИЯ ДУИОПА ЗАЯВЛЕНИЯ НА ПЕРЕВОД*/
  FUNCTION GET_CLAIM_TRANSFER_SUMM_SPIS
    (
    P_CLAIM_TRANSFER_ IN NUMBER
    ) RETURN NUMBER;

  /*ФУНКЦИЯ ВОЗВРАЩАЕТ ДАТУ СПИСАНИЯ ДУИОПА ЗАЯВЛЕНИЯ НА ПЕРЕВОД*/
  FUNCTION GET_CLAIM_TRANSFER_DATE_SPIS
    (
    P_CLAIM_TRANSFER_ IN NUMBER
    ) RETURN DATE;

  /*ФУНКЦИЯ ВОЗВРАЩАЕТ СУММУ СПИСАНИЯ ДУИОПА ЗАЯВЛЕНИЯ НА ВЫПЛАТУ*/
  FUNCTION GET_CLAIM_PAY_OUT_SUMM_SPIS
    (
    P_CLAIM_PAY_OUT_ IN NUMBER
    )
  RETURN NUMBER;

  /*ФУНКЦИЯ ВОЗВРАЩАЕТ ДАТУ СПИСАНИЯ ДУИОПА ЗАЯВЛЕНИЯ НА ВЫПЛАТУ*/
  FUNCTION GET_CLAIM_PAY_OUT_DATE_SPIS
    (
    P_CLAIM_PAY_OUT_ IN NUMBER
    )
  RETURN DATE;

  /*ФУНКЦИЯ ВОЗВРАЩАЕТ СУММУ СПИСАНИЯ ДУИОПА ЗАЯВЛЕНИЯ НА ПЕРЕВОД МЕЖДУ ПОРТФЕЛЯМИ*/
  FUNCTION GET_CLAIM_TRANS_PRTF_SUMM_SPIS
    (
    P_CLAIM_TRANS_PRTF_ IN NUMBER
    ) RETURN NUMBER;

  /*ФУНКЦИЯ ВОЗВРАЩАЕТ ДАТУ СПИСАНИЯ ДУИОПА ЗАЯВЛЕНИЯ НА ПЕРЕВОД*/
  FUNCTION GET_CLAIM_TRANS_PRTF_DATE_SPIS
    (
    P_CLAIM_TRANS_PRTF_ IN NUMBER
    ) RETURN DATE;

  FUNCTION GET_INPUT_TRANSFER_IN_PERIOD
  (
    P_CONTRACT_ IN NUMBER,
    DATE_BEGIN_ IN DATE,
    DATE_END_   IN DATE
  )
  RETURN NUMBER;

  FUNCTION GET_OUTPUT_TRANSFER_IN_PERIOD
  (
    P_CONTRACT_ IN NUMBER,
    DATE_BEGIN_ IN DATE,
    DATE_END_   IN DATE
  )
  RETURN NUMBER;

  --функция возвращает дату первой выплаты произведеной по вкладчику
  FUNCTION GET_FIRST_PAY_DATE
    (
      G_PERSON_ IN NUMBER
    ) RETURN DATE;

  -- функция возвращает причину первой выплаты произведеной по вкладчику
  FUNCTION GET_FIRST_PAY_REASON
  (
    G_PERSON_ IN NUMBER
  )
  RETURN VARCHAR2;

  -- функция возвращает причину выплаты произведеной по вкладчику
  FUNCTION GET_PAY_REASON
  (
    G_PERSON_ IN NUMBER,
    NUM_      IN NUMBER
  )
  RETURN VARCHAR2;

  -- функция возвращает дату второй выплаты произведеной по вкладчику
  FUNCTION GET_PAY_DATE
  (
    G_PERSON_ IN NUMBER,
    NUM_      IN NUMBER
  )
  RETURN DATE;

  -- функция возвращает сумму первой выплаты произведеной по вкладчику
  FUNCTION GET_FIRST_PAY_SUMM
  (
    G_PERSON_ IN NUMBER
  )
  RETURN NUMBER;

  -- функция возвращает дату второй выплаты произведеной по вкладчику
  FUNCTION GET_SECOND_PAY_DATE
  (
    G_PERSON_ IN NUMBER
  )
  RETURN DATE;

  -- функция возвращает причину второй выплаты произведеной по вкладчику
  FUNCTION GET_SECOND_PAY_REASON
  (
    G_PERSON_ IN NUMBER
  )
  RETURN VARCHAR2;

  -- функция возвращает сумму второй выплаты произведеной по вкладчику
  FUNCTION GET_SECOND_PAY_SUMM
  (
    G_PERSON_ IN NUMBER
  )
  RETURN NUMBER;

  -- функция возвращает дату третей выплаты произведеной по вкладчику
  FUNCTION GET_THIRD_PAY_DATE
  (
    G_PERSON_ IN NUMBER
  )
  RETURN DATE;

  -- функция возвращает причину третей выплаты произведеной по вкладчику
  FUNCTION GET_THIRD_PAY_REASON
  (
    G_PERSON_ IN NUMBER
  )
  RETURN VARCHAR2;

  -- функция возвращает сумму третей выплаты произведеной по вкладчику
  FUNCTION GET_THIRD_PAY_SUMM
  (
    G_PERSON_ IN NUMBER
  )
  RETURN NUMBER;

  -- функция возвращает дату последнего перевода в другой фонд до 01.06.2006г. по вкладчику
  FUNCTION GET_LAST_TRANSFER_DATE
  (
    G_PERSON_ IN NUMBER
  )
  RETURN DATE;

  -- функция возвращает код фонда в который последний раз переводились накопления до 01.06.2006г. по вкладчику
  FUNCTION GET_LAST_TRANSFER_FUND
  (
    G_PERSON_ IN NUMBER
  )
  RETURN VARCHAR2;

  -- функция возвращает сумму, которая последний раз переводилась в др. фонд до 01.06.2006г. по вкладчику
  FUNCTION GET_LAST_TRANSFER_SUMM
  (
    G_PERSON_ IN NUMBER
  )
  RETURN NUMBER;

  -- функция возвращает НПФ из которого поступили деньги
  FUNCTION GET_G_PERSON_BY_P_OPR_IN
  (
    P_OPR_  IN NUMBER
  )
  RETURN VARCHAR2;

  -- функция возвращает все операции автопереводов произведеных по договору вкладчика
  FUNCTION GET_P_CONTRACT_AUTOTRANSFER
  (
    P_CONTRACT_  IN NUMBER
  )
  RETURN VARCHAR2;

  -- функция возвращает 1-если человек на дату являлся вкладчиком, 0-если на тот момент не являлся
  FUNCTION GET_RECIPIENT_IS_DEPOSITOR
  (
    G_PERSON_ IN NUMBER,
    DATE_     IN DATE
  )
  RETURN NUMBER;

  /*ВОЗВРАЩАЕТ ID  СЧЕТА ИМЕННО ИПС С УЧЕТОМ МУЛЬТИПОРФЕЛЯ*/
  FUNCTION P_GET_G_ACCOUNT_IPC
    (
    P_CONTRACT_ IN P_CONTRACT.P_CONTRACT%TYPE,
    PORTFOLIO_  IN P_G_PORTFOLIO.P_G_PORTFOLIO%TYPE
    ) RETURN G_ACCOUNT.G_ACCOUNT%TYPE;

  /*ГЕНЕРАЦИЯ НОМЕРА ИПС*/
  FUNCTION P_GENERATE_CONTRACT_NUM
    (
    CONTRACT_KND_      IN P_CONTRACT.P_G_CONTRACT_KND%TYPE,
    G_FILIAL_PARENT_   IN P_CONTRACT.G_FILIAL_PARENT%TYPE
    ) RETURN VARCHAR2;

  /*ГЕНЕРАЦИЯ НОМЕРА СЧЕТА*/
  FUNCTION P_GENERATE_CODE_ACC
    (
    P_CONTRACT_        IN P_CONTRACT.P_CONTRACT%TYPE,
    P_G_PORTFOLIO_     IN P_G_PORTFOLIO.P_G_PORTFOLIO%TYPE,
    P_G_ACCKND_        IN P_G_ACCKND.P_G_ACCKND%TYPE
    ) RETURN VARCHAR2;

  /*ВОЗВРАЩАЕТ 0 ИЛИ 1, ПРИЗНАК АКТИВНОСТИ ДОГОВОРА ПО ДАННОМУ ПОЛУЧАТЕЛЮ
   ЕСЛИ ХОТЬ ОДИН ИЗ ДОГОВОРОВ ЗАКРЫТЫЙ ТО 1 ИНАЧЕ 0*/
  FUNCTION P_GET_IS_ACTIV_CONTRACT
    (
    G_PERSON_RECIPIENT_ IN P_CONTRACT.G_PERSON_RECIPIENT%TYPE
    ) RETURN NUMBER;

  /*ВОЗВРАЩАЕТ G_PERSON (ПОЛУЧАТЕЛЬ) ПО КОНКРЕТНОМУ КОНТРАКТУ*/
  FUNCTION P_GET_CONTRACT_G_PERSON
    (
    P_CONTRACT_  IN P_CONTRACT.P_CONTRACT%TYPE
    ) RETURN P_CONTRACT.G_PERSON_RECIPIENT%TYPE;

  -------------------------------------------------------------
  /* Темеков А.А.
     Функция возвращает ФИО вкладчика по контракту
  */
  -------------------------------------------------------------
  FUNCTION P_GET_FIO_BY_CONTRACT(
    P_CONTRACT_ IN NUMBER
  )
  RETURN VARCHAR2;

  /*ВОЗВРАЩАЕТ СИК ПО КОНКРЕТНОМУ G_PERSON (ВКЛАДЧИК)*/
  FUNCTION P_GET_G_PERSON_SIC
    (
    G_PERSON_  IN G_NAT_PERSON.G_PERSON%TYPE
    ) RETURN G_NAT_PERSON.OPV%TYPE;

  -------------------------------------------------------------
  -- Возвращает контракт по G_Person
  -- Темеков А.А. 06.02.2012
  -- беру открытый ОПВ/ТД/ДППВ/ДПВ, если только закрытые, то с макс датой открытия
  -------------------------------------------------------------
  FUNCTION P_GET_CONTRACT_BY_G_PERSON(
    G_PERSON_ in P_CONTRACT.P_CONTRACT%type
  ) RETURN P_CONTRACT.P_CONTRACT%type;

  -------------------------------------------------------------
  -- Возвращает актуальный(последний) контракт по G_Person
  -- Темеков А.А. 18.05.2012
  -- приоритет ОПВ, если закрыт, проверяю на открытый ТД,
  -- если все закрыты, то опять же беру последний ОПВ -> ТД
  -------------------------------------------------------------
  FUNCTION P_GET_CONTRACT_BY_G_PERSON_TD(
    G_PERSON_ in P_CONTRACT.P_CONTRACT%type
  ) RETURN P_CONTRACT.P_CONTRACT%type;

 /*ВОЗВРАЩАЕТ ВИД ДОГОВОРА ПО КОНКРЕТНОМУ КОНТРАКТУ*/
  FUNCTION P_GET_CONTRACT_KND
    (
    P_CONTRACT_  IN P_CONTRACT.P_CONTRACT%TYPE
    ) RETURN P_CONTRACT.P_G_CONTRACT_KND%TYPE;

  /*ВОЗВРАЩАЕТ ПОРТФЕЛЬ Т.Е. НА КАКОМ ПОРТФЕЛЕ НАХОДИТСЯ КОНКРЕТНЫЙ КОНТРАКТ*/
  FUNCTION P_GET_CONTRACT_PORTFOLIO
    (
    P_CONTRACT_  IN P_CONTRACT.P_CONTRACT%TYPE
    ) RETURN P_G_PORTFOLIO.P_G_PORTFOLIO%TYPE;

  /*ВОЗВРАЩАЕТ ВИД ЮРИДИЧЕСКОГО ЛИЦА ПО КОНКРЕТНОМУ G_PERSON*/
  FUNCTION P_GET_G_PERSON_KND
    (
    G_PERSON_  IN G_PERSON.G_PERSON%TYPE
    ) RETURN G_PERSON.G_PERSON_KIND%TYPE;

-- *****   INSERT  *****
  /* Вставка записи в таблицу P_Account_State */
  PROCEDURE INSERT_P_ACCOUNT_STATE(
    G_ACCOUNT_          IN  G_ACCOUNT.G_ACCOUNT%TYPE,
    WORKING_DATE_       IN  WORKING_DATE.WORKING_DATE%TYPE,
    WORK_DATE_          IN  WORKING_DATE.WORK_DATE%TYPE,
    ERR_CODE            OUT	TYPES.TERR_CODE,
    ERR_MSG	            OUT	TYPES.TERR_MSG);

-- *****   UPDATE  *****


-- *****   DELETE  *****
    PROCEDURE PRC04(
        P_                                 IN P_G_FILE_GCVP_FORMAT.P_G_FILE_GCVP_FORMAT%TYPE,
        PARAM_                             IN NUMBER, -- не используется, зарезервировано
    	  ERR_CODE	                        OUT	TYPES.TERR_CODE,
      	ERR_MSG	                          OUT	TYPES.TERR_MSG
        );

-- ====================================================================================================================
-- ===============================    CHECKS   ========================================================================
-- ====================================================================================================================
    -- Темеков А.А. 14,05,2011
    -- есть ли физ лицо с такими же ФИО, дата рождения и пол
    FUNCTION IS_SUCH_PERSON_EXIST(
        fm_                IN  g_nat_person.fm%type,
        nm_                IN  g_nat_person.nm%type,
        ft_                IN  g_nat_person.ft%type,
        dt_                IN  g_nat_person.dt%type,
        g_sex_             IN  g_nat_person.g_sex%type,
        ERR_CODE           OUT  TYPES.TERR_CODE,
        ERR_MSG            OUT  TYPES.TERR_MSG
        ) RETURN NUMBER;

    -- Темеков А.А. 22.06,2011
    -- открыт или закрыт контракт, тип контракта
    FUNCTION IS_CONTRACT_IS_OPEN(
      P_CONTRACT_        IN  P_CONTRACT.P_CONTRACT%type
      ) RETURN NUMBER;

    FUNCTION Get_Sum_OPV_By_Period(
    ---Функция фозвращает сумму обязательных взносов клиента
    -- за заданный перод в разрезе контрактов или по филиално
      P_Contract_        IN  P_CONTRACT.P_CONTRACT%type default null,
      G_Filial_          In  G_FILIAL.G_FILIAL%type default null,
      Begin_Date_        in Date,
      End_Date_          in Date
      ) RETURN k_Types.TSumm_18_2;

    FUNCTION Get_Sum_TransferIn_By_Period(
    ---Функция фозвращает сумму входящих переводов
    -- за заданный перод в разрезе контрактов или по филиално
      P_Contract_        IN  P_CONTRACT.P_CONTRACT%type default null,
      G_Filial_          In  G_FILIAL.G_FILIAL%type default null,
      Begin_Date_        in Date,
      End_Date_          in Date
      ) RETURN k_Types.TSumm_18_2;

     FUNCTION Get_Sum_TransferOut_By_Period(
    ---Функция фозвращает сумму исходящих переводов
    -- за заданный перод в разрезе контрактов или по филиално
      P_Contract_        IN  P_CONTRACT.P_CONTRACT%type default null,
      G_Filial_          In  G_FILIAL.G_FILIAL%type default null,
      Begin_Date_        in Date,
      End_Date_          in Date
      ) RETURN k_Types.TSumm_18_2;

      FUNCTION Get_Cnt_OPV_By_Period(
    ---Функция фозвращает количество обязательных взносов клиента
    -- за заданный перод в разрезе контрактов или по филиално
      P_Contract_        IN  P_CONTRACT.P_CONTRACT%type default null,
      G_Filial_          In  G_FILIAL.G_FILIAL%type default null,
      Begin_Date_        in Date,
      End_Date_          in Date
      ) RETURN k_Types.TSumm_18_2;

    FUNCTION Get_Cnt_TransferIn_By_Period(
    ---Функция фозвращает количество входящих переводов
    -- за заданный перод в разрезе контрактов или по филиално
      P_Contract_        IN  P_CONTRACT.P_CONTRACT%type default null,
      G_Filial_          In  G_FILIAL.G_FILIAL%type default null,
      Begin_Date_        in Date,
      End_Date_          in Date
      ) RETURN k_Types.TSumm_18_2;

     FUNCTION Get_Cnt_TransferOut_By_Period(
    ---Функция фозвращает количество исходящих переводов
    -- за заданный перод в разрезе контрактов или по филиално
      P_Contract_        IN  P_CONTRACT.P_CONTRACT%type default null,
      G_Filial_          In  G_FILIAL.G_FILIAL%type default null,
      Begin_Date_        in Date,
      End_Date_          in Date
      ) RETURN k_Types.TSumm_18_2;

     function Get_Month_Name
  -------------------------------------------------------------------------
  -- Функция возвращает название месяца на заданном языке в заданном падеже
  -------------------------------------------------------------------------
    (
    Month_    In Integer,
    Case_     In Integer,
    Language_ In SmallInt default 0
    ) return VarChar2;

    function Get_PayOut_Official_Date
-------------------------------------------------------------------------
-- Функция возвращает дату изменения статуса таблицы выплаты
-------------------------------------------------------------------------
  (
  P_Claim_Pay_Out_ In P_CLAIM_PAY_OUT.P_CLAIM_PAY_OUT  % type,
  Status_          In P_CLAIM_PAY_OUT.P_G_CLAIM_STATUS % type
  )
return P_CLAIM_PAY_OUT_OFFICIAL.CONFIRM_DATE % type;

   function Get_Transfer_Official_Date
-------------------------------------------------------------------------
-- Функция возвращает дату изменения статуса таблицы переводов
-------------------------------------------------------------------------
  (
  P_Claim_Transfer_ In P_CLAIM_TRANSFER.P_CLAIM_TRANSFER  % type,
  Status_           In P_CLAIM_TRANSFER.P_G_CLAIM_STATUS  % type
  )
return P_CLAIM_TRANSFER_OFFICIAL.CONFIRM_DATE % type;

-- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ПЕНСИОННЫХ НАКОПЛЕНИИ НА ПОРТФЕЛЕ ДОГОВОРА, БЕЗ ОБРАБОТКИ ОШИБОК, ДЛЯ ИСПОЛЬЗОВАНИЯ В СЕЛЕКТАХ
FUNCTION GET_P_CONTRACT_PRTF_BALANCE(
  P_CONTRACT_    IN  P_CONTRACT.P_CONTRACT%TYPE,
  P_G_PORTFOLIO_ IN  P_G_PORTFOLIO.P_G_PORTFOLIO%TYPE
) RETURN NUMBER;


-- ФУНКЦИЯ ПОЛУЧЕНИЯ СУММЫ ПОРОГА ДОСТАТОЧНОСТИ ИЗ ТАБЛИЦЫ P_G_SUFFICIENCY_LEVEL - СПРАВОЧНИК ПОРОГОВ ДОСТАТОЧНОСТИ ПО ВОЗРАСТАМ, С ИСТОРИЕЙ
FUNCTION GET_SUM_SUFFICIENCY_LEVEL(
  G_PERSON_       IN NUMBER,
  DATE_RECEPTION_ IN DATE
) RETURN NUMBER;
  

-- ФУНКЦИЯ ВОЗВРАЩАЕТ ЗАДОЛЖЕННОСТЬ ОТЛОЖЕННОГО ИПН ПО ДОГОВОРУ/ВКЛАДЧИКУ
FUNCTION GET_SUMM_TAX_DEFERRAL(
  P_CONTRACT_       IN NUMBER,
  G_PERSON_         IN NUMBER
) RETURN NUMBER;

-- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ОСТАТКА ОТЛОЖЕННОГО ИПН ПО ДОГОВОРУ НА ДАТУ, БЕЗ ОБРАБОТКИ ОШИБОК, ДЛЯ ИСПОЛЬЗОВАНИЯ В СЕЛЕКТАХ
FUNCTION GET_SUMM_TAX_DEFERRAL_DATE(
    P_CONTRACT_    IN  P_CONTRACT.P_CONTRACT%TYPE,
    DATE_ID_       IN NUMBER,
    DATE_          IN DATE
    ) RETURN NUMBER;
    
FUNCTION GET_MRP_SUMM_BEG_OF_YEAR(
        DATE_        IN  DATE,
        ERR_CODE     OUT  TYPES.TERR_CODE,
        ERR_MSG      OUT  TYPES.TERR_MSG
        ) RETURN NUMBER;
        
FUNCTION GET_MIN_SALARY_SUM_BEG_OF_YEAR(
        DATE_               IN  DATE,
        ERR_CODE           OUT  TYPES.TERR_CODE,
        ERR_MSG            OUT  TYPES.TERR_MSG
        ) RETURN NUMBER;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ МЕСЯЧНОГО НАЛОГОВОГО ВЫЧЕТА (СОЗДАНА 28.12.2021 БЫЧКОВЫМ)
    -- до 31.12.2021 предоставлялся вычет в размере 1 МЗП
    --  с 01.01.2022 вычет применяемый к месячному доходу равен 12*МРП
    FUNCTION GET_MONTH_DEDUCTION(
        DATE_               IN  DATE,
        ERR_CODE           OUT  TYPES.TERR_CODE,
        ERR_MSG            OUT  TYPES.TERR_MSG
        ) RETURN NUMBER;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ МЕСЯЧНОГО НАЛОГОВОГО ВЫЧЕТА (СОЗДАНА 28.12.2021 БЫЧКОВЫМ)
    -- до 31.12.2021 предоставлялся вычет в размере 1 МЗП
    --  с 01.01.2022 вычет применяемый к месячному доходу равен 12*МРП
    FUNCTION GET_MONTH_DEDUCTION_BEG_OF_YY(
        DATE_               IN  DATE,
        ERR_CODE           OUT  TYPES.TERR_CODE,
        ERR_MSG            OUT  TYPES.TERR_MSG
        ) RETURN NUMBER;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ СУММЫ, ДОСТУПНОЙ ДЛЯ ПЕРЕВОДА В УИП С УКАЗАННОГО ИПС НА УКАЗАННУЮ ДАТУ (СОЗДАНА 17.04.2023 БЫЧКОВЫМ)
    FUNCTION GET_SUMM_AVAIL_FOR_UIP(
        P_CONTRACT_       IN NUMBER,
        DATE_             IN DATE
        ) RETURN NUMBER;
    -- Функция определения года выхода на пенсию
    FUNCTION fldPensionDate (vldDT IN DATE, vliG_Sex IN NUMBER) RETURN DATE;

END PENSION_PACK;
/
CREATE OR REPLACE PACKAGE BODY PENSION_PACK IS
  -- История изменений:
  -- Дата        Кто             Comments  где изменялось
  ----------------------------------------------------------------------------------------------
  -- 07.12.2017  Omirbaev Timur  Доработал внути пакета функцию P_GET_RECIPIENT_SUMM_YEAR, в ней при вызове функции p_get_recipient_summ_year_hybr добавили параметр IS_OLD_ALGORITHM_ => 1
  -- 15.06.2018  ТЕМЕКОВ АА      Добавил пакетную переменную, которая будет использоваться для вычисления годовой суммы при создании заявления, если 1 - значит заявление создается через ГК, 0 - обычно
  -- 28.12.2021  БЫЧКОВ М.       СОЗДАЛ ФУНКЦИЮ ВЫЧИСЛЕНИЯ МЕСЯЧНОГО НАЛОГОВОГО ВЫЧЕТА В СВЯЗИ С ИЗМЕНЕНИЯМИ НАЛОГОВОГО ЗАКОНОДАТЕЛЬСТВА
  -- 14.05.2022  Бычков М.       Чтобы не рисковать, решил изменить функцию GET_MONTH_DEDUCTION
  -- 19.04.2023  Бычков М.       Сделал функцию GET_SUMM_AVAIL_FOR_UIP
  -- 01.03.2024  Тайканов Е.Р.   Сделал функцию fldPensionDate  для определения года выхода на пенсию
  -- 17.11.2025  Бычков          Спрячем долги по налогам после даты вступления в силу Налогового кодекса 01.01.2026
  ----------------------------------------------------------------------------------------------

-- ====================================================================================================================
--                                            READ
-- ====================================================================================================================
/*
    FUNCTION GET_CONTRACT_SUMM_BEGIN_YEAR(
        P_CONTRACT_                        IN NUMBER,
        DATE_                              IN DATE,
        ERR_CODE                          OUT  TYPES.TERR_CODE,
        ERR_MSG                           OUT  TYPES.TERR_MSG
        ) RETURN NUMBER
    IS
       -- ФУНКЦИЯ ВОЗВРАЩАЕТ ОСТАТОК НА ИПС ПО СОСТОЯНИЮ НА НАЧАЛО ГОДА.

       PROCNAME                    CONSTANT  TYPES.TPROC_NAME :=  'PENSION_PACK.GET_CONTRACT_SUMM_BEGIN_YEAR';
       SUMM_REMAIN_YEAR_ NUMBER;
       DATE_TRANSFER_ DATE;
       WORK_DATE_     DATE;
       P_OPR_         NUMBER;
       RESULT NUMBER;
    BEGIN
        ERR_CODE := 0;
        ERR_MSG  := '';

     -- если функция вызвана из другого места
     -- то мы должны определить остаток на ИПС по состоянию на начало года (ето что он был ВИП-ом или не был ВИП-ом
     -- фиксируется на весь год по тому состоянию в котором он был в начале года)

     -- 1. вызывается функция Серика, определяющая остаток на ИПС, в качестве даты передавать первое января
     -- 2. Если эта вкладчика не было  в фонде на начало года или у него остаток ноль на начало года, то эта функция вернет ноль
     -- тогда ищу первый входящий перевод по ОПВ в этом году, если нахожу - то сумма этого перевода и есть остаток на ИПС на начало года
     -- (на всякий случай если нашел операцию перевода надо взять все входящие переводы в течение 30 календ дней после первого перевода
     -- на тот случай вдруг ему не все деньги за раз из другого фонда перевели)

     -- ОПРЕДЕЛЯЕМ ОСТАТОК НА ИПС НА НАЧАЛО ГОДА, ВЫЗЫВАЕМ ФУНКЦИЮ СЕРИКА
     SUMM_REMAIN_YEAR_ := GET_CONTRACT_SUMM_ON_DATE(P_CONTRACT_, TO_DATE('01.01.'||TO_CHAR(DATE_,'YYYY'),'DD.MM.YYYY')) + P_GET_UE(P_CONTRACT_,TO_DATE('01.01.'||TO_CHAR(DATE_,'YYYY'),'DD.MM.YYYY')) ;

     -- ЕСЛИ ЭТОГО ВКЛАДЧИКА НЕ БЫЛО НА НАЧАЛО ГОДА, ЛИБО У ЭТОТ ВКЛАДЧИК БЫЛО, НО НЕ БЫЛО НАКОПЛЕНИЙ, ТО...
     IF NVL(SUMM_REMAIN_YEAR_,0) = 0 THEN
       BEGIN
           SELECT MIN(W3.WORK_DATE)
             INTO WORK_DATE_
             FROM P_OPR O3,
                  WORKING_DATE W3,
                  P_G_OPRKND K3
            WHERE O3.P_CONTRACT = P_CONTRACT_ AND
                  --O3.P_G_OPRKND IN (28, 31, 34) AND
                  K3.P_G_OPRKND = O3.P_G_OPRKND AND
                  K3.P_G_GROUP_OPRKND IN (3,33) AND
                  O3.WORKING_DATE = W3.WORKING_DATE AND
                  TO_CHAR(W3.WORK_DATE,'YYYY') = TO_CHAR(DATE_,'YYYY');

           SELECT
                  MAX(O2.P_OPR)
             INTO P_OPR_
             FROM P_OPR O2,
                  WORKING_DATE W2,
                  P_G_OPRKND K2
            WHERE O2.P_CONTRACT = P_CONTRACT_ AND
                  --O2.P_G_OPRKND IN (28, 31, 34) AND
                  K2.P_G_OPRKND = O2.P_G_OPRKND AND
                  K2.P_G_GROUP_OPRKND IN (3,33) AND
                  W2.WORKING_DATE = O2.WORKING_DATE AND
                  W2.WORK_DATE = WORK_DATE_;

           -- ВЫЧИСЛЯЕМ ПЕРВЫЙ ВХОДЯЩИЙ ПЕРЕВОД В ЭТОМ ГОДУ
           SELECT W.WORK_DATE
             INTO DATE_TRANSFER_
             FROM P_OPR O,
                  WORKING_DATE W,
                  P_G_OPRKND K
            WHERE O.P_CONTRACT = P_CONTRACT_ AND
                  --O.P_G_OPRKND IN (28, 31, 34) AND
                  K.P_G_OPRKND = O.P_G_OPRKND AND
                  K.P_G_GROUP_OPRKND IN (3,33) AND
                  O.P_OPR = P_OPR_ AND
                  W.WORKING_DATE = O.WORKING_DATE;

           -- ВЫЧИСЛЯЕМ ОСТАЛЬНЫЕ ПЕРЕВОДЫ В ТЕЧЕНИИ МЕСЯЦА(ПОСЛЕДУЮЩИХ 30 ДНЕЙ)
           SELECT
              SUM(O.SUMMA) + P_GET_UE(P_CONTRACT_, DATE_TRANSFER_)
             INTO SUMM_REMAIN_YEAR_
             FROM P_OPR O,
                  WORKING_DATE W,
                  P_G_OPRKND K
            WHERE O.P_CONTRACT = P_CONTRACT_ AND
                  --O.P_G_OPRKND IN (28, 31, 34) AND
                  K.P_G_OPRKND = O.P_G_OPRKND AND
                  K.P_G_GROUP_OPRKND IN (3,33) AND
                  O.WORKING_DATE = W.WORKING_DATE AND
                  W.WORK_DATE = DATE_TRANSFER_; --BETWEEN DATE_TRANSFER_ AND DATE_TRANSFER_ + 30;
       EXCEPTION
         WHEN OTHERS THEN
           SUMM_REMAIN_YEAR_ := 0;
       END;
     END IF;

     RESULT := SUMM_REMAIN_YEAR_;

     RETURN(RESULT);

    EXCEPTION
      WHEN OTHERS THEN
    		ERR_CODE := SQLCODE;
    		ERR_MSG  := PROCNAME || ' 00' || ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, SQLERRM);
        ROLLBACK;
    END GET_CONTRACT_SUMM_BEGIN_YEAR;
*/

-- ====================================================================================================================
--                                         GET
-- ====================================================================================================================
    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ОСТАТКА НА ВСЕХ СЧЕТАХ ДОГОВОРА,КРОМЕ ОБЩИХ (ОСТАТОК НА ДОГОВОРЕ)
    FUNCTION GET_CONTRACT_SUMM(
        P_CONTRACT_        IN  P_CONTRACT.P_CONTRACT%TYPE,
    	  ERR_CODE	         OUT TYPES.TERR_CODE,
      	ERR_MSG	           OUT TYPES.TERR_MSG
        ) RETURN NUMBER
    IS
        RESULT        NUMBER;
        DATE_         DATE;
        OUTPUT_       NUMBER;
    BEGIN

      -- 17.11.2022      Тайканов Е.Р.             В рамках интеграции пенсионных систем ЕАЭС добавил p_g_group_accknd = 21
      RESULT := 0;

      FOR REC IN(SELECT P_G_PORTFOLIO
                   FROM P_G_PORTFOLIO
                  WHERE IS_ACTIVE = 1)
      LOOP
        BEGIN
          SELECT /*+INDEX(PS IND_P_STATE_LAST) */ SUM(NVL(PS.OUTPUT, 0))
            INTO OUTPUT_
            FROM P_ACC PA,
                 P_G_ACCKND PK,
                 P_ACCOUNT_STATE PS
           WHERE PA.P_CONTRACT = P_CONTRACT_
             AND PA.G_ACCOUNT = PS.G_ACCOUNT
             AND PA.P_G_ACCKND = PK.P_G_ACCKND
             AND PK.P_G_GROUP_ACCKND in (1, 11, 21)
             AND PK.P_G_PORTFOLIO = REC.P_G_PORTFOLIO
             AND PS.IS_LAST = 1
             /*Закомитил Серик: Думаю что так будет работать быстрее, не нужно использовать нижнии селект, так как последний остаток
               могу вытащить по признаку IS_LAST = 1.*/
             /*AND PS.WORKING_DATE IN (SELECT W.WORKING_DATE
                                       FROM WORKING_DATE W
                                      WHERE W.WORK_DATE = (SELECT MAX(W2.WORK_DATE)
                                                             FROM WORKING_DATE W2,
                                                                  P_ACCOUNT_STATE PS2,
                                                                  P_ACC PA2,
                                                                  P_G_ACCKND PK2
                                                            WHERE PS2.WORKING_DATE = W2.WORKING_DATE AND
                                                                  PA2.G_ACCOUNT = PS2.G_ACCOUNT AND
                                                                  PA2.P_CONTRACT = P_CONTRACT_ AND
                                                                  PA2.P_G_ACCKND = PK2.P_G_ACCKND AND
                                                                  PK2.P_G_GROUP_ACCKND in (1, 11) AND
                                                                  PK2.P_G_PORTFOLIO = REC.P_G_PORTFOLIO))*/
             ;
        EXCEPTION
          WHEN OTHERS THEN
             RESULT := 0;
        END;
        RESULT := RESULT + NVL(OUTPUT_, 0);
      END LOOP;

      RETURN(NVL(RESULT,0));

    EXCEPTION
      WHEN OTHERS THEN
  			ERR_CODE := SQLCODE;
  			ERR_MSG  := ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, SQLERRM);
    END;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ОСТАТКА НА ВСЕХ СЧЕТАХ ДОГОВОРА,КРОМЕ ОБЩИХ (ОСТАТОК НА ДОГОВОРЕ), БЕЗ ОБРАБОТКИ ОШИБОК, ДЛЯ ИСПОЛЬЗОВАНИЯ В СЕЛЕКТАХ
    FUNCTION GET_CONTRACT_SUMM(
        P_CONTRACT_        IN  P_CONTRACT.P_CONTRACT%TYPE
        ) RETURN NUMBER
    IS
        RESULT        NUMBER;
        DATE_         DATE;
        WORKING_DATE_ NUMBER;
        OUTPUT_       NUMBER;
    BEGIN
      -- 17.11.2022      Тайканов Е.Р.             В рамках интеграции пенсионных систем ЕАЭС добавил p_g_group_accknd = 21
      RESULT := 0;

      FOR REC IN(SELECT P_G_PORTFOLIO
                   FROM P_G_PORTFOLIO
                  WHERE IS_ACTIVE = 1)
      LOOP
        BEGIN
          SELECT /*+INDEX(PS IND_P_STATE_LAST) */ SUM(NVL(PS.OUTPUT, 0))
            INTO OUTPUT_
            FROM P_ACC PA,
                 P_G_ACCKND PK,
                 P_ACCOUNT_STATE PS
           WHERE PA.P_CONTRACT = P_CONTRACT_
             AND PA.G_ACCOUNT = PS.G_ACCOUNT
             AND PA.P_G_ACCKND = PK.P_G_ACCKND
             AND PK.P_G_GROUP_ACCKND in (1, 11, 21)
             AND PK.P_G_PORTFOLIO = REC.P_G_PORTFOLIO
             AND PS.IS_LAST = 1
             /*Закомитил Серик: Думаю что так будет работать быстрее, не нужно использовать нижнии селект, так как последний остаток
               могу вытащить по признаку IS_LAST = 1.*/

             /*AND PS.WORKING_DATE IN (SELECT W.WORKING_DATE
                                       FROM WORKING_DATE W
                                      WHERE W.WORK_DATE = (SELECT MAX(W2.WORK_DATE)
                                                             FROM WORKING_DATE W2,
                                                                  P_ACCOUNT_STATE PS2,
                                                                  P_ACC PA2,
                                                                  P_G_ACCKND PK2
                                                            WHERE PS2.WORKING_DATE = W2.WORKING_DATE AND
                                                                  PA2.G_ACCOUNT = PS2.G_ACCOUNT AND
                                                                  PA2.P_CONTRACT = P_CONTRACT_ AND
                                                                  PA2.P_G_ACCKND = PK2.P_G_ACCKND AND
                                                                  PK2.P_G_GROUP_ACCKND in (1, 11) AND
                                                                  PK2.P_G_PORTFOLIO = REC.P_G_PORTFOLIO))*/
             ;
        EXCEPTION
          WHEN OTHERS THEN
             RESULT := 0;
        END;
        RESULT := RESULT + NVL(OUTPUT_, 0);
      END LOOP;

      RETURN(NVL(RESULT,0));
    END;

    -- ФУНКЦИЯ ВЫЧИСЛЯЕТ ОСТАТОК ДОГОВОРА В ТЕНГЕ И В УЕ
    FUNCTION GET_CONTRACT_BALANCE_AMOUNT(
        /*ID договора*/
        P_CONTRACT_    IN  P_CONTRACT.P_CONTRACT%TYPE,
        /*Признак что нам возвращать: 0-сумма в тенге, 1-сумма а УЕ*/
        IS_SUMM_       IN  INTEGER DEFAULT 0
        ) RETURN NUMBER
    IS
        RESULT        NUMBER;
        PORTFOLIO_    NUMBER;
        G_ACCOUNT_    NUMBER;
    BEGIN
      RESULT := 0;

      PORTFOLIO_ := P_GET_CONTRACT_PORTFOLIO(P_CONTRACT_);
      G_ACCOUNT_ := P_GET_G_ACCOUNT_IPC(P_CONTRACT_, PORTFOLIO_);

      SELECT DECODE(IS_SUMM_,0, NVL(SUM(s.OUTPUT), 0), NVL(SUM(s.OUTPUT_CU), 0))
        INTO RESULT
        FROM P_ACCOUNT_STATE s
       WHERE s.G_ACCOUNT = G_ACCOUNT_
         AND s.IS_LAST = 1;


      RETURN(NVL(RESULT,0));
    END;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ОСТАТКА НА ВСЕХ СЧЕТАХ ДОГОВОРА ЗА ДАТУ
    FUNCTION GET_CONTRACT_SUMM_ON_DATE(
        P_CONTRACT_  IN P_CONTRACT.P_CONTRACT%TYPE,
        DATE_        IN DATE
        ) RETURN NUMBER
    IS
        RESULT NUMBER;
        BEGIN_DATE_  DATE;
        P_G_PORTFOLIO_ NUMBER;
    BEGIN
        BEGIN

          /*СЕРИК 14-06-2018. РЕШИЛ УБРАТЬ ВЫЧИСЛЕНИЯ ПОРТФЕЛЕЙ, ТАК КАК СИСТЕМА РАБОТАЕТ ДАВНО УЖЕ БЕЗ ПОРТФЕЛЕЙ И НА ВРЯТЛИ БУДЕТ РАБОТАТЬ КОГДА ЛИБО.
          ПО УМОЛЧАНИЮ СЕЙЧАС ВСЕ ДОГОВОРА СИДЯТ В УМЕРЕННОМ ПОРТФЕЛЕ*/
          P_G_PORTFOLIO_ := 1;
          /*BEGIN
            SELECT MAX(C.BEGIN_DATE)
              INTO BEGIN_DATE_
              FROM P_CONTRACT_HIS C
             WHERE C.P_CONTRACT = P_CONTRACT_ AND
                   C.BEGIN_DATE <= DATE_;

            SELECT P.P_G_PORTFOLIO
              INTO P_G_PORTFOLIO_
              FROM P_CONTRACT_HIS C,
                   P_CONTRACT_PORTFOLIO_HIS P
             WHERE C.P_CONTRACT = P_CONTRACT_ AND
                   P.P_CONTRACT_HIS = C.P_CONTRACT_HIS AND
                   C.BEGIN_DATE = BEGIN_DATE_;
          EXCEPTION
            WHEN OTHERS THEN
              P_G_PORTFOLIO_ := NULL;
          END;*/

          RESULT := 0;
          -- 24-02-2021: МАМЕТОВ СЕРИК АЛИМАМЕТОВИЧ: РАНЕЕ Я ДУМАЛ, ЧТО МУЛЬТИПОРТФЕЛИ НЕ ЗАРАБОТАЮТ НИКОГДА, НО
          -- Я ОШИБАЛСЯ, ОНИ ЗАРАБОТАЛИ, НО НАЗЫВАВАЮТСЯ ИНАЧЕ, НАЗЫВАЮТСЯ ТЕПЕРЬ ВСЕ ЭТО ДЕЛО УИПами
          -- ТЕПЕРЬ, ОСТАТКИ НАДО ПОКАЗЫВАТЬ НА КАЖДОМ УИП. ПОЭТОМУ УБЕРАЮ КОД НИЖЕ И ПИШУ ЦИКЛ ПО ПОРТФЕЛЯМ
          -- ДАННОГО ИПС (УИПам)
          /*IF P_G_PORTFOLIO_ IS NOT NULL THEN
            RESULT := RESULT + NVL( GET_P_CONTRACT_PRTF_SUMM_DATE(P_CONTRACT_,P_G_PORTFOLIO_,DATE_) ,0);
          ELSE
            RESULT := RESULT + NVL( GET_P_CONTRACT_PRTF_SUMM_DATE(P_CONTRACT_,1,DATE_) ,0);
            RESULT := RESULT + NVL( GET_P_CONTRACT_PRTF_SUMM_DATE(P_CONTRACT_,2,DATE_) ,0);
            RESULT := RESULT + NVL( GET_P_CONTRACT_PRTF_SUMM_DATE(P_CONTRACT_,3,DATE_) ,0);
          END IF;*/

          FOR REC IN (SELECT O.P_G_PORTFOLIO
                        FROM P_CONTRACT_PORTFOLIO O
                       WHERE O.P_CONTRACT = P_CONTRACT_)
          LOOP
            RESULT := RESULT + NVL(GET_P_CONTRACT_PRTF_SUMM_DATE(P_CONTRACT_, REC.P_G_PORTFOLIO, DATE_), 0);
          END LOOP;

        EXCEPTION
          WHEN OTHERS THEN
             RESULT := 0;
        END;
        RETURN(RESULT);
    END;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ОСТАТКА НА ВСЕХ СЧЕТАХ ВКЛАДЧИКА ЗА ДАТУ
    FUNCTION GET_G_PERSON_SUMM_ON_DATE(
        G_PERSON_     IN P_CONTRACT.G_PERSON_RECIPIENT%TYPE,
        WORKING_DATE_ IN WORKING_DATE.WORKING_DATE%TYPE
        ) RETURN NUMBER
    IS
        RESULT NUMBER;
        DATE_BEGIN_  DATE;
    BEGIN
        BEGIN
          /*SELECT MAX(W2.WORK_DATE)
            INTO DATE_BEGIN_
            FROM WORKING_DATE W2,
                 P_ACCOUNT_STATE PS2,
                 P_ACC PA2,
                 P_CONTRACT P
           WHERE PS2.WORKING_DATE = W2.WORKING_DATE AND
                 PA2.G_ACCOUNT = PS2.G_ACCOUNT AND
                 W2.WORK_DATE < DATE_ AND
                 PA2.P_CONTRACT = P.P_CONTRACT AND
                 P.G_PERSON_RECIPIENT = G_PERSON_;

          SELECT SUM(NVL(PS.OUTPUT, 0))
            INTO RESULT
            FROM P_CONTRACT P,
                 P_ACC PA,
                 P_G_ACCKND PK,
                 P_ACCOUNT_STATE PS,
                 WORKING_DATE W
           WHERE P.G_PERSON_RECIPIENT = G_PERSON_
             AND P.P_CONTRACT = PA.P_CONTRACT
             AND PA.G_ACCOUNT = PS.G_ACCOUNT
             AND PA.P_G_ACCKND = PK.P_G_ACCKND
             AND PK.P_G_GROUP_ACCKND =1
             AND PS.WORKING_DATE = W.WORKING_DATE
             AND W.WORK_DATE = DATE_BEGIN_;*/
          SELECT SUM(NVL(PS.OUTPUT, 0))
            INTO RESULT
            FROM P_CONTRACT P,
                 P_ACC PA,
                 P_G_ACCKND PK,
                 P_ACCOUNT_STATE PS
           WHERE P.G_PERSON_RECIPIENT = G_PERSON_
             AND P.P_CONTRACT = PA.P_CONTRACT
             AND PA.G_ACCOUNT = PS.G_ACCOUNT
             AND PA.P_G_ACCKND = PK.P_G_ACCKND
             AND PK.P_G_GROUP_ACCKND in (1, 11)
             AND PS.WORKING_DATE = (SELECT MAX(T.WORKING_DATE)
                                      FROM P_ACCOUNT_STATE T
                                     WHERE T.G_ACCOUNT = PS.G_ACCOUNT
                                       AND T.WORKING_DATE <= WORKING_DATE_);
        EXCEPTION
          WHEN OTHERS THEN
             RESULT := 0;
        END;
        RETURN(RESULT);
    END;
    
    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ОСТАТКА НА ВСЕХ СЧЕТАХ ВКЛАДЧИКА ЗА ДАТУ
    FUNCTION GET_G_PERSON_SUMM_SAL_ON_DATE(
        G_PERSON_     IN P_CONTRACT.G_PERSON_RECIPIENT%TYPE,
        WORKING_DATE_ IN WORKING_DATE.WORKING_DATE%TYPE
        ) RETURN NUMBER
    IS
        RESULT_ NUMBER := 0;
        ACC_BALANCE_ NUMBER;
        A NUMBER;
        B NUMBER;
    BEGIN
        BEGIN
          FOR PC IN (SELECT PC.P_CONTRACT 
                       FROM MAIN.P_CONTRACT PC 
                      WHERE PC.G_PERSON_RECIPIENT = G_PERSON_)
          LOOP
            BEGIN
           SELECT ROUND(GET_ACCOUNT_OUTPUT_CU(MAIN.PENSION_PACK.P_GET_G_ACCOUNT_IPC(PC.P_CONTRACT, 1), WORKING_DATE_, WORKING_DATE_) *
                        MAIN.K_CURRENCY_COURSE_PACK.GET_PENSION_COURSE_REC(1, WORKING_DATE_), 2)
            INTO ACC_BALANCE_ 
            FROM DUAL;
            RESULT_:=RESULT_+ACC_BALANCE_;
            EXCEPTION
              WHEN OTHERS THEN 
                ACC_BALANCE_ := 0;
            END;            
          END LOOP;  
        EXCEPTION
          WHEN OTHERS THEN
             RESULT_ := 0;
        END;
        RETURN(RESULT_);
    END;    

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ОСТАТКА НА ПОРТФЕЛЕ, БЕЗ ОБРАБОТКИ ОШИБОК, ДЛЯ ИСПОЛЬЗОВАНИЯ В СЕЛЕКТАХ
    FUNCTION GET_CONTRACT_PRTF_SUMM(
        P_CONTRACT_PORTFOLIO_        IN  P_CONTRACT_PORTFOLIO.P_CONTRACT_PORTFOLIO%TYPE
        ) RETURN NUMBER
    IS
        RESULT        NUMBER;
    BEGIN
        BEGIN
            SELECT SUM(PS.OUTPUT)
              INTO RESULT
              FROM P_CONTRACT_PORTFOLIO PF,
                   P_ACC PA,
                   P_G_ACCKND PK,
                   P_ACCOUNT_STATE PS
             WHERE PF.P_CONTRACT_PORTFOLIO = P_CONTRACT_PORTFOLIO_
               AND PA.P_CONTRACT = PF.P_CONTRACT
               AND PA.G_ACCOUNT = PS.G_ACCOUNT
               AND PA.P_G_ACCKND = PK.P_G_ACCKND
               AND PK.P_G_PORTFOLIO = PF.P_G_PORTFOLIO
               AND PK.P_G_GROUP_ACCKND in (1, 11)/*
               AND PS.WORKING_DATE = (SELECT MAX(W.WORKING_DATE)
                                        FROM WORKING_DATE W)*/;
        EXCEPTION
          WHEN OTHERS THEN
            RESULT := 0;
        END;
        RETURN(NVL(RESULT,0));
    END;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ОСТАТКА НА ПОРТФЕЛЕ ДОГОВОРА, БЕЗ ОБРАБОТКИ ОШИБОК, ДЛЯ ИСПОЛЬЗОВАНИЯ В СЕЛЕКТАХ
    FUNCTION GET_P_CONTRACT_PRTF_SUMM(
        P_CONTRACT_    IN  P_CONTRACT.P_CONTRACT%TYPE,
        P_G_PORTFOLIO_ IN  P_G_PORTFOLIO.P_G_PORTFOLIO%TYPE
        ) RETURN NUMBER
    IS
        RESULT        NUMBER;
        WORKING_DATE_ NUMBER;
    BEGIN
        BEGIN
          SELECT MAX(W.WORKING_DATE)
            INTO WORKING_DATE_
            FROM WORKING_DATE W,
                 P_ACC PA,
                 P_G_ACCKND PK,
                 P_ACCOUNT_STATE PS
           WHERE PA.P_CONTRACT = P_CONTRACT_
             AND PA.G_ACCOUNT = PS.G_ACCOUNT
             AND PA.P_G_ACCKND = PK.P_G_ACCKND
             AND PK.P_G_PORTFOLIO = P_G_PORTFOLIO_
             AND PK.P_G_GROUP_ACCKND in (1, 11)
             AND W.WORKING_DATE = PS.WORKING_DATE;

            SELECT SUM(PS.OUTPUT)
              INTO RESULT
              FROM P_ACC PA,
                   P_G_ACCKND PK,
                   P_ACCOUNT_STATE PS
             WHERE PA.P_CONTRACT = P_CONTRACT_
               AND PA.G_ACCOUNT = PS.G_ACCOUNT
               AND PA.P_G_ACCKND = PK.P_G_ACCKND
               AND PK.P_G_PORTFOLIO = P_G_PORTFOLIO_
               AND PK.P_G_GROUP_ACCKND in (1, 11)
               AND PS.WORKING_DATE = WORKING_DATE_;

        EXCEPTION
          WHEN OTHERS THEN
            RESULT := 0;
        END;
        RETURN(NVL(RESULT,0));
    END;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ИНВЕСТ ДОХОДА ПО ВСЕМ ПОРТФЕЛЯМ ВКЛАДЧИКА.
    -- ИНВЕСТ ДОХОД СЧИТАЕТСЯ ТОЛЬКО ПО КУРСУ НА ОТКРЫТУЮ ОПЕРАЦИОННУЮ ДАТУ
    FUNCTION GET_P_CONTRACT_SUMM_ID(
        P_CONTRACT_    IN  P_CONTRACT.P_CONTRACT%TYPE
        ) RETURN NUMBER
    IS
        RESULT        NUMBER;
        WORKING_DATE_ NUMBER;
        SALDO_        NUMBER;
        COURSE_       P_G_COURSE.COURSE%TYPE;
    BEGIN
        WORKING_DATE_ := CONNECTION_PARAM.IDOPERDAY;

        FOR REC IN (SELECT *
                      FROM P_CONTRACT_PORTFOLIO
                     WHERE P_CONTRACT = P_CONTRACT_)
        LOOP

          BEGIN
            SELECT SUM(PS.OUTPUT)
              INTO SALDO_
              FROM P_ACC PA,
                   P_G_ACCKND PK,
                   P_ACCOUNT_STATE PS
             WHERE PA.P_CONTRACT = REC.P_CONTRACT
               AND PA.G_ACCOUNT = PS.G_ACCOUNT
               AND PA.P_G_ACCKND = PK.P_G_ACCKND
               AND PK.P_G_PORTFOLIO = REC.P_G_PORTFOLIO
               AND PK.P_G_GROUP_ACCKND in (1, 11)
               AND PS.WORKING_DATE = WORKING_DATE_;
          EXCEPTION
            WHEN OTHERS THEN
              SALDO_ := 0;
          END;

          BEGIN
            SELECT COURSE
              INTO COURSE_
              FROM P_G_COURSE
             WHERE P_G_PORTFOLIO = REC.P_G_PORTFOLIO
               AND WORKING_DATE = WORKING_DATE_;
          EXCEPTION
            WHEN OTHERS THEN
              COURSE_ := 0;
          END;

          IF SALDO_ > 0 AND COURSE_ > 0 THEN
            RESULT := RESULT + ((COURSE_ * SALDO_) - SALDO_);
          END IF;
        END LOOP;

        RETURN(NVL(ROUND(RESULT, 2),0));
    END;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ОСТАТКА НА ПОРТФЕЛЕ ДОГОВОРА НА ДАТУ, БЕЗ ОБРАБОТКИ ОШИБОК, ДЛЯ ИСПОЛЬЗОВАНИЯ В СЕЛЕКТАХ
    FUNCTION GET_P_CONTRACT_PRTF_SUMM_DATE(
        P_CONTRACT_    IN  P_CONTRACT.P_CONTRACT%TYPE,
        P_G_PORTFOLIO_ IN  P_G_PORTFOLIO.P_G_PORTFOLIO%TYPE,
        DATE_          IN DATE
        ) RETURN NUMBER
    IS
        RESULT        NUMBER;
        WORKING_DATE_ NUMBER;
    BEGIN
        BEGIN
          SELECT MAX(W.WORKING_DATE)
            INTO WORKING_DATE_
            FROM WORKING_DATE W,
                 P_ACC PA,
                 P_G_ACCKND PK,
                 P_ACCOUNT_STATE PS
           WHERE PA.P_CONTRACT = P_CONTRACT_
             AND PA.G_ACCOUNT = PS.G_ACCOUNT
             AND PA.P_G_ACCKND = PK.P_G_ACCKND
             AND PK.P_G_PORTFOLIO = P_G_PORTFOLIO_
             AND PK.P_G_GROUP_ACCKND in (1, 11)
             AND W.WORKING_DATE = PS.WORKING_DATE
             AND W.WORK_DATE <= DATE_;

            SELECT NVL(SUM(PS.OUTPUT), 0)
              INTO RESULT
              FROM P_ACC PA,
                   P_G_ACCKND PK,
                   P_ACCOUNT_STATE PS
             WHERE PA.P_CONTRACT = P_CONTRACT_
               AND PA.G_ACCOUNT = PS.G_ACCOUNT
               AND PA.P_G_ACCKND = PK.P_G_ACCKND
               AND PK.P_G_PORTFOLIO = P_G_PORTFOLIO_
               AND PK.P_G_GROUP_ACCKND in (1, 11)
               AND PS.WORKING_DATE = WORKING_DATE_;

        EXCEPTION
          WHEN OTHERS THEN
            RESULT := 0;
        END;
        RETURN(NVL(RESULT,0));
    END;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ОСТАТКА НА ПОРТФЕЛЕ ДОГОВОРА НА ДАТУ, БЕЗ ОБРАБОТКИ ОШИБОК, ДЛЯ ИСПОЛЬЗОВАНИЯ В СЕЛЕКТАХ
    FUNCTION GET_P_CONTR_PRTF_SUMM_CU_DATE(
        P_CONTRACT_    IN  P_CONTRACT.P_CONTRACT%TYPE,
        P_G_PORTFOLIO_ IN  P_G_PORTFOLIO.P_G_PORTFOLIO%TYPE,
        DATE_          IN DATE
        ) RETURN NUMBER
    IS
        RESULT        NUMBER;
        WORKING_DATE_ NUMBER;
    BEGIN
        BEGIN
          SELECT MAX(W.WORKING_DATE)
            INTO WORKING_DATE_
            FROM WORKING_DATE W,
                 P_ACC PA,
                 P_G_ACCKND PK,
                 P_ACCOUNT_STATE PS
           WHERE PA.P_CONTRACT = P_CONTRACT_
             AND PA.G_ACCOUNT = PS.G_ACCOUNT
             AND PA.P_G_ACCKND = PK.P_G_ACCKND
             AND PK.P_G_PORTFOLIO = P_G_PORTFOLIO_
             AND PK.P_G_GROUP_ACCKND in (1, 11)
             AND W.WORKING_DATE = PS.WORKING_DATE
             AND W.WORK_DATE <= DATE_;

            SELECT SUM(PS.OUTPUT_CU)
              INTO RESULT
              FROM P_ACC PA,
                   P_G_ACCKND PK,
                   P_ACCOUNT_STATE PS
             WHERE PA.P_CONTRACT = P_CONTRACT_
               AND PA.G_ACCOUNT = PS.G_ACCOUNT
               AND PA.P_G_ACCKND = PK.P_G_ACCKND
               AND PK.P_G_PORTFOLIO = P_G_PORTFOLIO_
               AND PK.P_G_GROUP_ACCKND in (1, 11)
               AND PS.WORKING_DATE = WORKING_DATE_;

        EXCEPTION
          WHEN OTHERS THEN
            RESULT := 0;
        END;
        RETURN(NVL(RESULT,0));
    END;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ МИНИМАЛЬНОЙ ПЕНСИИ (МИНИМАЛЬНАЯ ПЕНСИЯ)
    FUNCTION GET_MIN_PENSION_SUMM(
        DATE_               IN  DATE,
        ERR_CODE           OUT  TYPES.TERR_CODE,
        ERR_MSG            OUT  TYPES.TERR_MSG
        ) RETURN NUMBER
    IS
        RESULT        NUMBER;
    BEGIN
        BEGIN
            SELECT G.VALUE
              INTO RESULT
              FROM G_MINIMAL_DESIGN_INDEX G
             WHERE G.G_PARAMETER = 2 AND
                   G.K_DAY = (SELECT MAX(G2.K_DAY)
                                FROM G_MINIMAL_DESIGN_INDEX G2
                               WHERE G2.G_PARAMETER = 2 AND
                                     G2.K_DAY <= DATE_
                               );
            IF RESULT < 0 THEN RESULT := 0; END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            SELECT G.VALUE
              INTO RESULT
              FROM G_MINIMAL_DESIGN_INDEX G
             WHERE G.G_PARAMETER = 2 AND
                   G.K_DAY = (SELECT MAX(G2.K_DAY)
                                FROM G_MINIMAL_DESIGN_INDEX G2
                               WHERE G2.G_PARAMETER = 2 AND
                                     G2.K_DAY <= TRUNC(SYSDATE)
                               );
            IF RESULT < 0 THEN RESULT := 0; END IF;
        END;
        RETURN(RESULT);
    END;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ МИНИМАЛЬНОЙ ЗАРАБОТНОЙ ПЛАТЫ
    FUNCTION GET_MIN_SALARY_SUMM(
        DATE_      IN  DATE,
        ERR_CODE   OUT TYPES.TERR_CODE,
        ERR_MSG    OUT TYPES.TERR_MSG
        ) RETURN NUMBER
    IS
      RESULT NUMBER;
    BEGIN
      ERR_CODE := 0;
      ERR_MSG  := NULL;
      BEGIN
        SELECT G.VALUE
          INTO RESULT
          FROM G_MINIMAL_DESIGN_INDEX G
         WHERE G.G_PARAMETER = 3 AND
               G.K_DAY = (SELECT MAX(G2.K_DAY)
                            FROM G_MINIMAL_DESIGN_INDEX G2
                           WHERE G2.G_PARAMETER = 3 AND
                                 TO_CHAR(G2.K_DAY, 'YYYY') = TO_CHAR(DATE_, 'YYYY')
                           );

      EXCEPTION
        WHEN OTHERS THEN
          ERR_CODE := SQLCODE;
          ERR_MSG  := 'ПОКАЗАТЕЛЬ "МИНИМАЛЬНОЙ ЗАРАБОТНОЙ ПЛАТА" ЗА ТЕКУЩИЙ ГОД НЕ ВВЕДЕНА СПРАВОЧНИК "РАСЧЕТНЫХ ПОКАЗАТЕЛЕЙ"';
      END;
      RETURN(RESULT);
    END;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ МРП
    FUNCTION GET_MRP_SUMM(
        DATE_        IN  DATE,
        ERR_CODE     OUT TYPES.TERR_CODE,
        ERR_MSG      OUT TYPES.TERR_MSG
        ) RETURN NUMBER
    IS
      RESULT NUMBER;
    BEGIN
      ERR_CODE := 0;
      ERR_MSG  := NULL;
      BEGIN
        SELECT G.VALUE
          INTO RESULT
          FROM G_MINIMAL_DESIGN_INDEX G
         WHERE G.G_PARAMETER = 1 AND
               G.K_DAY = (SELECT MAX(G2.K_DAY)
                            FROM G_MINIMAL_DESIGN_INDEX G2
                           WHERE G2.G_PARAMETER = 1 AND
                                 TO_CHAR(G2.K_DAY, 'YYYY') = TO_CHAR(DATE_, 'YYYY')
                           );
      EXCEPTION
        WHEN OTHERS THEN
          ERR_CODE := SQLCODE;
          ERR_MSG  := 'ПОКАЗАТЕЛЬ "МРП" ЗА ТЕКУЩИЙ ГОД НЕ ВВЕДЕНА СПРАВОЧНИК "РАСЧЕТНЫХ ПОКАЗАТЕЛЕЙ"';
      END;
      RETURN(RESULT);
    END;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ КОЭФФИЦИЕНТА ИЗЪЯТИЯ (КОЭФФИЦИЕНТ ИЗЪЯТИЯ)
    FUNCTION GET_WITHDRAW_KOEF(
        AGE_               IN   NUMBER,
        ERR_CODE           OUT  TYPES.TERR_CODE,
        ERR_MSG            OUT  TYPES.TERR_MSG
        ) RETURN NUMBER
    IS
        RESULT        NUMBER;
    BEGIN
        BEGIN
          SELECT G.KOEF
            INTO RESULT
            FROM P_G_WITHDRAW_KOEF G
           WHERE G.AGE = AGE_;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              SELECT G.KOEF
                INTO RESULT
                FROM P_G_WITHDRAW_KOEF G
               WHERE G.AGE = ( SELECT MAX(K.AGE)
                                 FROM P_G_WITHDRAW_KOEF K
                                WHERE K.AGE <= AGE_
                             );
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                RESULT := 0;
            END;
        END;

        IF RESULT < 0 THEN RESULT := 0; END IF;
        RETURN(RESULT);
    END;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ СТАВКИ ВЫПЛАТ ПЕНСИОННЫХ НАКОПЛЕНИЙ В %
    FUNCTION GET_PAYOUT_RATE(
        DATE_       IN DATE,
        ERR_CODE   OUT TYPES.TERR_CODE,
        ERR_MSG    OUT TYPES.TERR_MSG
        ) RETURN NUMBER
    IS
      RESULT NUMBER;
    BEGIN
      ERR_CODE := 0;
      ERR_MSG  := NULL;
      BEGIN
        SELECT G.VALUE
          INTO RESULT
          FROM G_MINIMAL_DESIGN_INDEX G
         WHERE G.G_PARAMETER = 17 AND
               G.K_DAY = (SELECT MAX(G2.K_DAY)
                            FROM G_MINIMAL_DESIGN_INDEX G2
                           WHERE G2.G_PARAMETER = 17 AND
                                 TO_CHAR(G2.K_DAY, 'YYYY') <= TO_CHAR(DATE_, 'YYYY')
                           );

      EXCEPTION
        WHEN OTHERS THEN
          ERR_CODE := SQLCODE;
          ERR_MSG  := 'ПОКАЗАТЕЛЬ "СТАВКА ВЫПЛАТ ПЕНСИОННЫХ НАКОПЛЕНИЙ В %" ЗА ТЕКУЩИЙ ГОД НЕ ВВЕДЕНА СПРАВОЧНИК "РАСЧЕТНЫХ ПОКАЗАТЕЛЕЙ"';
      END;
      RETURN(RESULT);
    END;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ СТАВКА ИНДЕКСАЦИИ ПЕНСИОННЫХ ВЫПЛАТ В %
    FUNCTION GET_PAYOUT_INDEXING_RATE(
        DATE_       IN DATE,
        ERR_CODE   OUT TYPES.TERR_CODE,
        ERR_MSG    OUT TYPES.TERR_MSG
        ) RETURN NUMBER
    IS
      RESULT NUMBER;
    BEGIN
      ERR_CODE := 0;
      ERR_MSG  := NULL;
      BEGIN
        SELECT G.VALUE
          INTO RESULT
          FROM G_MINIMAL_DESIGN_INDEX G
         WHERE G.G_PARAMETER = 18 AND
               G.K_DAY = (SELECT MAX(G2.K_DAY)
                            FROM G_MINIMAL_DESIGN_INDEX G2
                           WHERE G2.G_PARAMETER = 18 AND
                                 TO_CHAR(G2.K_DAY, 'YYYY') <= TO_CHAR(DATE_, 'YYYY')
                           );

      EXCEPTION
        WHEN OTHERS THEN
          ERR_CODE := SQLCODE;
          ERR_MSG  := 'ПОКАЗАТЕЛЬ "СТАВКА ИНДЕКСАЦИИ ПЕНСИОННЫХ ВЫПЛАТ В %" ЗА ТЕКУЩИЙ ГОД НЕ ВВЕДЕНА СПРАВОЧНИК "РАСЧЕТНЫХ ПОКАЗАТЕЛЕЙ"';
      END;
      RETURN(RESULT);
    END;


    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ПОПРАВОЧНОГО КОЭФФИЦИЕНТА К СТАВКЕ ВЫПЛАТ ПЕНСИОННЫХ НАКОПЛЕНИЙ ДЛЯ
    -- ПОЛУЧАТЕЛЕЙ ПЕНСИОННЫХ ВЫПЛАТ, ИМЕЮЩИХ ИНВАЛИДНОСТЬ ПЕРВОЙ/ВТОРОЙ ГРУППЫ,
    -- ЕСЛИ ИНВАЛИДНОСТЬ УСТАНОВЛЕНА БЕССРОЧНО
    FUNCTION GET_CORRECTIVE_COEFFICIENT(
        AGE_                IN  NUMBER,
        COR_COEF_KND_       IN  NUMBER,
        ERR_CODE           OUT  TYPES.TERR_CODE,
        ERR_MSG            OUT  TYPES.TERR_MSG
        ) RETURN NUMBER
    IS
        RESULT        NUMBER;
    BEGIN
        BEGIN
          SELECT G.VALUE
            INTO RESULT
            FROM P_G_CORRECTIVE_COEFFICIENT G
           WHERE G.AGE = AGE_
             AND G.CORRECTIVE_COEFFICIENT_KND = COR_COEF_KND_;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              SELECT G.VALUE
                INTO RESULT
                FROM P_G_CORRECTIVE_COEFFICIENT G
               WHERE G.AGE = ( SELECT MAX(K.AGE)
                                 FROM P_G_CORRECTIVE_COEFFICIENT K
                                WHERE K.AGE <= AGE_
                                AND G.CORRECTIVE_COEFFICIENT_KND = COR_COEF_KND_
                             )
                 AND G.CORRECTIVE_COEFFICIENT_KND = COR_COEF_KND_;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                RESULT := 0;
            END;
        END;

        IF RESULT < 0 THEN RESULT := 0; END IF;
        RETURN(RESULT);
    END;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ПОПРАВОЧНОГО КОЭФФИЦИЕНТА ОППВ
    FUNCTION GET_CORRECTIVE_COEF_OPPV(
        DATE_       IN DATE,
        ERR_CODE   OUT TYPES.TERR_CODE,
        ERR_MSG    OUT TYPES.TERR_MSG
        ) RETURN NUMBER
    IS
      RESULT NUMBER;
    BEGIN
      ERR_CODE := 0;
      ERR_MSG  := NULL;
      BEGIN
        SELECT G.VALUE
          INTO RESULT
          FROM G_MINIMAL_DESIGN_INDEX G
         WHERE G.G_PARAMETER = 19 AND
               G.K_DAY = (SELECT MAX(G2.K_DAY)
                            FROM G_MINIMAL_DESIGN_INDEX G2
                           WHERE G2.G_PARAMETER = 19 AND
                                 TO_CHAR(G2.K_DAY, 'YYYY') <= TO_CHAR(DATE_, 'YYYY')
                           );

      EXCEPTION
        WHEN OTHERS THEN
          ERR_CODE := SQLCODE;
          ERR_MSG  := 'ПОКАЗАТЕЛЬ "ПОПРАВОЧНЫЙ КОЭФФИЦИЕНТ ОППВ" ЗА ТЕКУЩИЙ ГОД НЕ ВВЕДЕНА СПРАВОЧНИК "РАСЧЕТНЫХ ПОКАЗАТЕЛЕЙ"';
      END;
      RETURN(RESULT);
    END;


    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ НАЧАЛА ПЕРИОДА В КАКОЙ ВХОДИТ ДАТА (КВАРТАЛ, ПОЛУГОДИЕ ...)
    FUNCTION GET_DATE_BEGIN_PERIOD(
        DATE_               IN  DATE,
        KOEF_               IN  NUMBER,
        ERR_CODE           OUT  TYPES.TERR_CODE,
        ERR_MSG            OUT  TYPES.TERR_MSG
        ) RETURN DATE
    IS
        RESULT        DATE;
        MM_           NUMBER;
    BEGIN
        MM_ := TO_NUMBER(TO_CHAR(DATE_,'MM'));
        -- ЕЖЕМЕСЯЧНО
        IF KOEF_ = 12 THEN
           RESULT := TO_DATE('01.'||TO_CHAR(DATE_,'MM.YYYY'),'DD.MM.YYYY');
        -- ЕЖЕКВАРТАЛЬНО
        ELSIF KOEF_ = 4 THEN
           IF MM_ IN (1,2,3) THEN
              RESULT := TO_DATE('01.01.'||TO_CHAR(DATE_,'YYYY'),'DD.MM.YYYY');
           ELSIF MM_ IN (4,5,6) THEN
              RESULT := TO_DATE('01.04.'||TO_CHAR(DATE_,'YYYY'),'DD.MM.YYYY');
           ELSIF MM_ IN (7,8,9) THEN
              RESULT := TO_DATE('01.07.'||TO_CHAR(DATE_,'YYYY'),'DD.MM.YYYY');
           ELSIF MM_ IN (10,11,12) THEN
              RESULT := TO_DATE('01.10.'||TO_CHAR(DATE_,'YYYY'),'DD.MM.YYYY');
           END IF;
        -- ПОЛУГОДИЕ
        ELSIF KOEF_ = 2 THEN
           IF MM_ IN (1,2,3,4,5,6) THEN
              RESULT := TO_DATE('01.01.'||TO_CHAR(DATE_,'YYYY'),'DD.MM.YYYY');
           ELSIF MM_ IN (7,8,9,10,11,12) THEN
              RESULT := TO_DATE('01.07.'||TO_CHAR(DATE_,'YYYY'),'DD.MM.YYYY');
           END IF;
        -- ГОД
        ELSIF KOEF_ = 1 THEN
           RESULT := TO_DATE('01.01.'||TO_CHAR(DATE_,'YYYY'),'DD.MM.YYYY');
        END IF;

        RETURN(RESULT);
    END;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ НАЧАЛА ПЕРИОДА В КАКОЙ ВХОДИТ ДАТА (КВАРТАЛ, ПОЛУГОДИЕ ...)
    FUNCTION GET_DATE_END_PERIOD(
        DATE_               IN  DATE,
        KOEF_               IN  NUMBER,
        ERR_CODE           OUT  TYPES.TERR_CODE,
        ERR_MSG            OUT  TYPES.TERR_MSG
        ) RETURN DATE
    IS
        RESULT        DATE;
        MM_           NUMBER;
    BEGIN
        MM_ := TO_NUMBER(TO_CHAR(DATE_,'MM'));
        -- ЕЖЕМЕСЯЧНО
        IF KOEF_ = 12 THEN
           RESULT := LAST_DAY(TO_DATE('01.'||TO_CHAR(DATE_,'MM.YYYY'),'DD.MM.YYYY'));
        -- ЕЖЕКВАРТАЛЬНО
        ELSIF KOEF_ = 4 THEN
           IF MM_ IN (1,2,3) THEN
              RESULT := LAST_DAY(TO_DATE('01.03.'||TO_CHAR(DATE_,'YYYY'),'DD.MM.YYYY'));
           ELSIF MM_ IN (4,5,6) THEN
              RESULT := LAST_DAY(TO_DATE('01.06.'||TO_CHAR(DATE_,'YYYY'),'DD.MM.YYYY'));
           ELSIF MM_ IN (7,8,9) THEN
              RESULT := LAST_DAY(TO_DATE('01.09.'||TO_CHAR(DATE_,'YYYY'),'DD.MM.YYYY'));
           ELSIF MM_ IN (10,11,12) THEN
              RESULT := LAST_DAY(TO_DATE('01.12.'||TO_CHAR(DATE_,'YYYY'),'DD.MM.YYYY'));
           END IF;
        -- ПОЛУГОДИЕ
        ELSIF KOEF_ = 2 THEN
           IF MM_ IN (1,2,3,4,5,6) THEN
              RESULT := LAST_DAY(TO_DATE('01.06.'||TO_CHAR(DATE_,'YYYY'),'DD.MM.YYYY'));
           ELSIF MM_ IN (7,8,9,10,11,12) THEN
              RESULT := LAST_DAY(TO_DATE('01.12.'||TO_CHAR(DATE_,'YYYY'),'DD.MM.YYYY'));
           END IF;
        -- ГОД
        ELSIF KOEF_ = 1 THEN
           RESULT := TO_DATE('31.12.'||TO_CHAR(DATE_,'YYYY'),'DD.MM.YYYY');
        END IF;

        RETURN(RESULT);
    END;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ПЕРИОДИЧНОСТИ ГРАФИКА (КВАРТАЛ, ПОЛУГОДИЕ ...)
    FUNCTION GET_GRF_PERIOD(
        P_GRF_              IN  NUMBER
        ) RETURN VARCHAR2
    IS

        RESULT        VARCHAR2(100);
        KOEF_         NUMBER;
        DT_           DATE;
        YEAR_         VARCHAR2(10);
        STR_          VARCHAR2(50);
    BEGIN
        /*
        15.06.2018 Темеков АА, старый вариант оставил, теперь по-другому будет периодичность вызываться зависеть от дат
        SELECT D.COUNT_IN_YEAR
          INTO KOEF_
          FROM P_GRFRCT A,
               P_GRF B,
               P_CLAIM_PAY_OUT C,
               G_TYPE_PERIOD D
         WHERE B.P_GRF = P_GRF_ AND
               A.P_GRFRCT = B.P_GRFRCT AND
               C.P_CLAIM_PAY_OUT = A.P_CLAIM_PAY_OUT AND
               D.G_TYPE_PERIOD = C.G_TYPE_PERIOD;

        SELECT A.DATE_1,
               TO_CHAR(A.DATE_1,'YYYY')
          INTO DT_,
               YEAR_
          FROM P_GRF A
         WHERE A.P_GRF = P_GRF_;

        STR_ := ' '||TO_CHAR(DT_,'YYYY')||' года';
        -- ГОД
        IF KOEF_ = 1 THEN
              RESULT := TO_CHAR(DT_,'YYYY')||' год';
        -- ПОЛУГОДИЕ
        ELSIF KOEF_ = 2 THEN
              IF TO_NUMBER(TO_CHAR(DT_,'MM')) <=6 THEN
                 RESULT := 'первое полугодие'||STR_;
              ELSE
                 RESULT := 'второе полугодие'||STR_;
              END IF;
        -- ЕЖЕКВАРТАЛЬНО
        ELSIF KOEF_ = 4 THEN
              IF TO_NUMBER(TO_CHAR(DT_,'MM')) IN (1,2,3) THEN
                 RESULT := 'первый квартал'||STR_;
              ELSIF TO_NUMBER(TO_CHAR(DT_,'MM')) IN (4,5,6) THEN
                 RESULT := 'второй квартал'||STR_;
              ELSIF TO_NUMBER(TO_CHAR(DT_,'MM')) IN (7,8,9) THEN
                 RESULT := 'третий квартал'||STR_;
              ELSIF TO_NUMBER(TO_CHAR(DT_,'MM')) IN (10,11,12) THEN
                 RESULT := 'четвёртый квартал'||STR_;
              END IF;
        -- ЕЖЕМЕСЯЧНО
        ELSIF KOEF_ = 12 THEN
              RESULT := MonthInWord(DT_)||STR_;
        END IF;*/

        SELECT ROUND(MONTHS_BETWEEN(T.DATE_2, T.DATE_1)),
               T.DATE_1
          INTO KOEF_,
               DT_
          FROM P_GRF T
         WHERE T.P_GRF = P_GRF_;

        STR_ := ' '||TO_CHAR(DT_,'YYYY')||' года';

        IF KOEF_ = 1 THEN
          RESULT := MonthInWord(DT_)||STR_;
        ELSIF KOEF_ = 3 THEN
          IF TO_NUMBER(TO_CHAR(DT_,'MM')) IN (1,2,3) THEN
             RESULT := 'первый квартал'||STR_;
          ELSIF TO_NUMBER(TO_CHAR(DT_,'MM')) IN (4,5,6) THEN
             RESULT := 'второй квартал'||STR_;
          ELSIF TO_NUMBER(TO_CHAR(DT_,'MM')) IN (7,8,9) THEN
             RESULT := 'третий квартал'||STR_;
          ELSIF TO_NUMBER(TO_CHAR(DT_,'MM')) IN (10,11,12) THEN
             RESULT := 'четвёртый квартал'||STR_;
          END IF;
        ELSIF KOEF_ = 6 THEN
          IF TO_NUMBER(TO_CHAR(DT_,'MM')) <=6 THEN
             RESULT := 'первое полугодие'||STR_;
          ELSE
             RESULT := 'второе полугодие'||STR_;
          END IF;
        ELSIF KOEF_ = 12 THEN
          RESULT := TO_CHAR(DT_,'YYYY')||' год';
        END IF;

        RETURN(RESULT);
    END;

    -- ФУНКЦИЯ ВЫЧИСЛЯЕТ ПОРЯДКОВЫЙ НОМЕР ПЕРИОДА ВЫПЛАТЫ В ГОДУ ПО ДАТЕ (ЕСЛИ КВАРТАЛ, ТО 1-ЫЙ, ЛИБО 2-ОЙ, ЛИБО 3-ИЙ, ЛИБО 4-ЫЙ В ЗАВИСИМОТИ ОТ ДАТ)
    -- НАПРИМЕР 13.05.2011, ПЕРИОДИЧНОСТЬ 4-КВАРТАЛ: ФУНКЦИЯ ВЕРНЕТ НОМЕР КВАРТАЛА В КОТОРЫЙ ПОПАДАЕТ ДАТА "DATE_", РЕЗУЛЬТАТ=2 - 13.05.2011 ВХОДИТ ВО ВТОРОЙ КВАРТАЛ
    FUNCTION GET_PERIOD_NUM(
        DATE_              IN  DATE, -- ДАТА, НА КОТОРУЮ НУЖНО ВЫЧИСЛИТЬ НОМЕР ПЕРИОДА
        KOEF_              IN NUMBER -- ПЕРИОДИЧНОСТЬ ВЫПЛАТ, 1-ГОД, 2-ПОЛУГОДИЕ, 4-КВАРТАЛ, 12-МЕСЯЦ
        ) RETURN NUMBER
    IS
        RESULT        VARCHAR2(100);
--        STR_          VARCHAR2(50);
    BEGIN
        -- ГОД
        IF KOEF_ = 1 THEN
              RESULT := 1;
        -- ПОЛУГОДИЕ
        ELSIF KOEF_ = 2 THEN
              IF TO_NUMBER(TO_CHAR(DATE_,'MM')) <= 6 THEN
                 RESULT := 1;
              ELSE
                 RESULT := 2;
              END IF;
        -- ЕЖЕКВАРТАЛЬНО
        ELSIF KOEF_ = 4 THEN
              IF TO_NUMBER(TO_CHAR(DATE_,'MM')) IN (1,2,3) THEN
                 RESULT := 1;
              ELSIF TO_NUMBER(TO_CHAR(DATE_,'MM')) IN (4,5,6) THEN
                 RESULT := 2;
              ELSIF TO_NUMBER(TO_CHAR(DATE_,'MM')) IN (7,8,9) THEN
                 RESULT := 3;
              ELSIF TO_NUMBER(TO_CHAR(DATE_,'MM')) IN (10,11,12) THEN
                 RESULT := 4;
              END IF;
        -- ЕЖЕМЕСЯЧНО
        ELSIF KOEF_ = 12 THEN
              --RESULT := MONTHS_BETWEEN(DATE_, TO_DATE('01.01.'||TO_CHAR(DATE_,'YYYY'),'DD.MM.YYYY'));
              RESULT := TO_NUMBER(TO_CHAR(DATE_,'MM'));
        END IF;

        RETURN(RESULT);
    END;

    -- ФУНКЦИЯ ОПРЕДЕЛЕНИЕ НАЛИЧИЯ КЗ У ВКЛАДЧИКА
    FUNCTION GET_IS_HAVE_KZ(
        G_PERSON_                          IN  NUMBER
        ) RETURN NUMBER
    IS
        RESULT            NUMBER;
        PROCNAME          CONSTANT  TYPES.TPROC_NAME :=  'PENSION_PACK.GET_IS_HAVE_KZ';
        G_ACCOUNT_        G_ACCOUNT.G_ACCOUNT % TYPE;
        SUMMA_            P_ACCOUNT_STATE.OUTPUT % TYPE;
        WORKING_DATE_REC_ K_TYPES.TCURRENT_WORKING_DATE_REC;
    BEGIN
        RESULT := 0;
        SUMMA_ := 0;
        --RETURN(RESULT);
        WORKING_DATE_REC_ := WORKING_DATE_PACK.GET_CURRENT_WORKING_DATE;

        BEGIN
          SELECT PA.G_ACCOUNT
            INTO G_ACCOUNT_
            FROM P_CONTRACT P,
                 P_ACC PA,
                 P_G_ACCKND PK
           WHERE P.G_PERSON_RECIPIENT = G_PERSON_
             AND P.P_G_CONTRACT_KND = 13
             AND P.P_CONTRACT = PA.P_CONTRACT
             AND PA.P_G_ACCKND = PK.P_G_ACCKND
             AND PK.P_G_GROUP_ACCKND = 11;
        EXCEPTION
          WHEN OTHERS THEN
            RESULT := 0;
        END;

        IF G_ACCOUNT_ > 0 THEN
          SUMMA_ := GET_ACCOUNT_OUTPUT(G_ACCOUNT_ => G_ACCOUNT_,
                                       WD_BEGIN_  => WORKING_DATE_REC_.WORKING_DATE,
                                       WD_END_    => WORKING_DATE_REC_.WORKING_DATE);
        END IF;

        IF SUMMA_ > 0 THEN
          RESULT := 1;
        ELSE
          RESULT := 0;
        END IF;

        RETURN(RESULT);

    EXCEPTION
      WHEN OTHERS THEN
        RETURN(0);
    END;

   /*ФУНКЦИЯ ВОЗВРАЩАЕТ ID ПОРТФЕЛЯ, ПО ID ОПЕРАЦИИ, Т.Е. ОПРЕДЕЛЯЕТ ПРЕНАДЛЕЖНОСТЬ ОПЕРАЦИИ К ТОМУ ИЛИ ИНОМУ ПОРТФЕЛЮ*/
   FUNCTION GET_PRTF_OWNER_OPR(
        P_OPR_  IN  P_OPR.P_OPR%TYPE
        ) RETURN NUMBER
    IS
        RESULT            NUMBER;
        PROCNAME          CONSTANT  TYPES.TPROC_NAME :=  'PENSION_PACK.GET_PRTF_OWNER_OPR';
    BEGIN
        RESULT := 1;

        BEGIN
          SELECT C.P_G_PORTFOLIO
            INTO RESULT
            FROM P_OPR P,
                 P_G_COURSE C
           WHERE P.P_OPR = P_OPR_
             AND P.P_G_COURSE = C.P_G_COURSE;
        EXCEPTION
          WHEN OTHERS THEN
            RESULT := 1;
        END;

        RETURN(RESULT);

    EXCEPTION
      WHEN OTHERS THEN
        RETURN(1);
    END;

    -- ФУНКЦИЯ ОПРЕДЕЛЕНИЯ ВОЗРАСТА ВКЛАДЧИКА
    FUNCTION GET_AGE_CONTRACT(
        P_CONTRACT_  IN P_CONTRACT.P_CONTRACT%TYPE,
        DATE_        IN DATE
    ) RETURN NUMBER
    IS
      RESULT        NUMBER;
    BEGIN
      SELECT TRUNC(MONTHS_BETWEEN(DATE_, N.DT)/12)
        INTO RESULT
        FROM G_NAT_PERSON N,
             P_CONTRACT P
       WHERE P.G_PERSON_RECIPIENT = N.G_PERSON AND
             P.P_CONTRACT = P_CONTRACT_;
      RETURN (RESULT);
   END;

  -- ФУНКЦИЯ ОПРЕДЕЛЯЕТ ЯВЛЯЕТСЯ ЛИ ВКЛАДЧИК НА ОПРЕДЕЛЕННУЮ ДАТУ ПЕНСИОНЕРОМ ИЛИ НЕТ
  -- СЕРИК 11/06/2012
  FUNCTION GET_IS_HAVE_PENSION_AGE(
       G_PERSON_  IN G_NAT_PERSON.G_PERSON%TYPE,
       DATE_      IN DATE
       )RETURN NUMBER
  IS RESULT        NUMBER;
     WORK_DATE_    DATE;
     YEARS_        NUMBER;
     AGE_MAN_      NUMBER;
     AGE_WOMAN_    NUMBER;
     DATE_MAN_     DATE;
     DATE_WOMAN_   DATE;
  BEGIN
    WORK_DATE_ := DATE_;
    -- ЛЕТ ДО ВЫХОДА НА ПЕНСИЮ
    YEARS_ := ADM.PARAMS.GET_SYSTEM_SETUP_PARAM('YEARS_BEFOR_PENSION');
    -- ВОЗРАСТ ВЫХОДА НА ПЕНСИЮ МУЖЧИН
    AGE_MAN_ := ADM.PARAMS.GET_SYSTEM_SETUP_PARAM('AGE_MAN');
    -- ВОЗРАСТ ВЫХОДА НА ПЕНСИЮ ЖЕНЩИН
    AGE_WOMAN_ := ADM.PARAMS.GET_SYSTEM_SETUP_PARAM('AGE_WOMAN');

    DATE_MAN_ := ADD_MONTHS(WORK_DATE_, (AGE_MAN_ - YEARS_) * -12);

    DATE_WOMAN_ := ADD_MONTHS(WORK_DATE_, (AGE_WOMAN_ - YEARS_) * -12);

    SELECT COUNT(np.G_PERSON)
      INTO RESULT
      FROM G_NAT_PERSON np
     WHERE np.G_PERSON = G_PERSON_
       AND ((np.G_SEX = 2 and TRUNC(np.DT) <= TRUNC(DATE_MAN_)) or
              (np.G_SEX = 3 and TRUNC(np.DT) <= TRUNC(DATE_WOMAN_))
             );

    RETURN(RESULT);
  END;

  FUNCTION P_GET_RECIPIENT_SUMM_YEAR
  (
    P_CONTRACT_  IN NUMBER,
    DATE_        IN DATE,
    SUMM_REMAIN_ IN NUMBER, -- ОСТАТОК НА ИПС, передается в любом случае и для ВИПои и не для ВИПов если эта функция вызывается при создании графика
                           --  ели эта функция вызывается из другого места - то передается NULL
    IS_VIP_     IN OUT PLS_INTEGER, -- ЕСЛИ ВХОДЯЩЕЕ ЗНАЧЕНИЕ = -1, ТО МАКСИМАЛЬНАЯ СУММА К ВУПЛАТЕ НЕ БУДЕТ ПЕРЕТЕРАТЬСЯ ОСТАТКОМ НА ИПС
                                    -- ОБРЕЗАЛОСЬ ВКОНЦЕ ПРИ УСЛОВИИ, ЧТО ОСТАТОК МЕНЬШЕ МАКСИМАЛЬНО ГОДОВОЙ СУММЫ
    ERR_CODE    OUT NUMBER,
    ERR_MSG     OUT VARCHAR2,
    P_CLAIM_PAY_OUT_ IN NUMBER DEFAULT NULL,
    IS_VIRTUAL_ IN NUMBER DEFAULT 0 -- ПРИЗНАК, ЧТО В ФУНКИЮ В КАЧЕСТВЕ SUMM_REMAIN_ ПЕРЕДАЕТСЯ ВИРТУАЛЬНЫЙ ОСТАТОК, КОТОРЫЙ БУДЕТ У ВКЛАДЧИКА В БУДУЩИХ ГОДАХ
  ) RETURN NUMBER
  IS
  /*
      ФУНКЦИЯ ВЫЧИСЛЯЕТ МАКСИМАЛЬНУЮ ГОДОВУЮ СУММУ ПОЛОЖЕННУЮ ВКЛАДЧИКУ только для заявлений по старому законодательству, действовавшему до 01.01.2018
      Максимальная годовая сумма пенсионных выплат рассчитывается в размере
      наибольшей из следующих величин:
      1)	тридцатикратного размера минимальной пенсии (размер минимальной пенсии должен задаваться
          в справочнике, справочник должен быть историческим);
      2)	двухсот пятидесяти тысяч тенге;
      3)	величины, рассчитанной как произведение суммы пенсионных накоплений
          на коэффициент текущей стоимости в соответствующем возрасте получателя
          согласно таблице

  */
    PROCNUM        CONSTANT TYPES.TPROC_NAME := 'P_GET_RECIPIENT_SUMM_YEAR';
    RESULT NUMBER;
    IGNORE_REMAIN_ NUMBER(1);
    v_ERR_CODE NUMBER;
    v_ERR_MSG VARCHAR2(1024);
    --V1_    NUMBER;
    --V2_    NUMBER;
    --V3_    NUMBER;
    --AGE_   NUMBER;
    --SUMM_  NUMBER;
    --SUMM_REMAIN_YEAR_ NUMBER;
    --DATE_TRANSFER_    DATE;
    --v_count           NUMBER;
    --IS_VIP_ORIGIN_    INTEGER;
    ARR_MIN_PENS_ ARR_MIN_PENS_TYPE; -- МАССИВ МИНИМАЛЬНЫХ ПЕНСИЙ ЭТОГО ГОДА, ЕГО ВОЗВРАЩАЕТ ФУНКЦИЯ ПО ОПРЕДЕЛЕНИЮ ГОДОВОЙ ГИБРИДНОЙ СУММЫ
    VIP_KOEF_ NUMBER;

  BEGIN

    IF NVL(IS_VIP_,0) = -1 THEN
      IGNORE_REMAIN_ := 0;
    ELSE
      IGNORE_REMAIN_ := 1;
    END IF;

    ARR_MIN_PENS_ := ARR_MIN_PENS_TYPE();
    RESULT := p_get_recipient_summ_year_hybr(p_contract_ => p_contract_,
                                             date_ => date_,
                                             summ_remain_ => summ_remain_,
                                             is_vip_ => is_vip_,
                                             p_claim_pay_out_ => P_CLAIM_PAY_OUT_,
                                             is_virtual_ => IS_VIRTUAL_,
                                             ignore_remain_ => IGNORE_REMAIN_,
                                             ARR_MIN_PENS_ => ARR_MIN_PENS_,
                                             VIP_KOEF_ => VIP_KOEF_,
                                             IS_OLD_ALGORITHM_ => 1, -- ПРИЗНАК ОБРАБОТКИ ЗАЯВЛЕНИЯ ПО СТАРОМУ ЗАКОНОДАТЕЛЬСТВУ, ДЕЙСТВУЮЩЕГО ДО 2018, ЕСЛИ 1 - ТО ПО СТАРОМУ ЗАКОНОДАТЕЛЬСТВУ, 0 - ПО НОВОМУ
                                             err_code => v_ERR_CODE,
                                             err_msg => v_ERR_MSG);
    IF v_ERR_CODE <> 0 THEN
      ERR_CODE := v_ERR_CODE;
      ERR_MSG := v_ERR_MSG;
      RAISE TYPES.E_Force_Exit;
    END IF;

    RETURN RESULT;

  EXCEPTION
    WHEN OTHERS THEN
      ERR_CODE := SQLCODE;
      ERR_MSG  := PROCNUM || ' 00 ' || ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, SQLERRM);
  END P_GET_RECIPIENT_SUMM_YEAR;

   /*ФУНКЦИЯ ВОЗВРАЩАЕТ ВХОДЯЩИЙ ОСТАТОК ПО СЧЕТУ*/
  /*Серик (весна 2011)*/
  FUNCTION GET_ACCOUNT_INPUT
    (
    G_ACCOUNT_ IN INTEGER,
    WD_BEGIN_  IN INTEGER,
    WD_END_    IN INTEGER
    )
  RETURN NUMBER
  IS
    RESULT NUMBER;
    CNT    INTEGER;
  BEGIN

    SELECT COUNT(1)
      INTO CNT
      FROM P_ACCOUNT_STATE
     WHERE G_ACCOUNT = G_ACCOUNT_
       AND WORKING_DATE >= WD_BEGIN_
       AND WORKING_DATE <= WD_END_
       AND ROWNUM < 2;

    IF CNT > 0 THEN
      SELECT K.INPUT
        INTO RESULT
        FROM P_ACCOUNT_STATE K,
            (SELECT MIN(K1.WORKING_DATE) AS WORKING_DATE
               FROM P_ACCOUNT_STATE K1
              WHERE K1.G_ACCOUNT = G_ACCOUNT_
                AND K1.WORKING_DATE >= WD_BEGIN_
                AND K1.WORKING_DATE <= WD_END_) X
       WHERE K.WORKING_DATE = X.WORKING_DATE
         AND K.G_ACCOUNT = G_ACCOUNT_;
    ELSE
      SELECT K.OUTPUT
        INTO RESULT
        FROM P_ACCOUNT_STATE K,
            (SELECT MAX(K1.WORKING_DATE) AS WORKING_DATE
               FROM P_ACCOUNT_STATE K1
              WHERE K1.G_ACCOUNT = G_ACCOUNT_
                AND K1.WORKING_DATE <= WD_BEGIN_) X
       WHERE K.WORKING_DATE = X.WORKING_DATE
         AND K.G_ACCOUNT = G_ACCOUNT_;
    END IF;
    RETURN NVL(RESULT, 0.0000);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0.0000;
  END;

   /*ФУНКЦИЯ ВОЗВРАЩАЕТ ВХОДЯЩИЙ ОСТАТОК ПО СЧЕТУ УЕ*/
  /*Серик (весна 2011)*/
  FUNCTION GET_ACCOUNT_INPUT_CU
    (
    G_ACCOUNT_ IN INTEGER,
    WD_BEGIN_  IN INTEGER,
    WD_END_    IN INTEGER
    )
  RETURN NUMBER
  IS
    RESULT NUMBER;
    CNT    INTEGER;
  BEGIN

    SELECT COUNT(1)
      INTO CNT
      FROM P_ACCOUNT_STATE
     WHERE G_ACCOUNT = G_ACCOUNT_
       AND WORKING_DATE >= WD_BEGIN_
       AND WORKING_DATE <= WD_END_
       AND ROWNUM < 2;

    IF CNT > 0 THEN
      SELECT K.INPUT_CU
        INTO RESULT
        FROM P_ACCOUNT_STATE K,
             (SELECT MIN(K1.WORKING_DATE) AS WORKING_DATE
                FROM P_ACCOUNT_STATE K1
               WHERE K1.G_ACCOUNT = G_ACCOUNT_
                 AND K1.WORKING_DATE >= WD_BEGIN_
                 AND K1.WORKING_DATE <= WD_END_) X
       WHERE K.WORKING_DATE = X.WORKING_DATE
         AND K.G_ACCOUNT = G_ACCOUNT_;
    ELSE
      SELECT K.OUTPUT_CU
        INTO RESULT
        FROM P_ACCOUNT_STATE K,
             (SELECT MAX(K1.WORKING_DATE) AS WORKING_DATE
                FROM P_ACCOUNT_STATE K1
               WHERE K1.G_ACCOUNT = G_ACCOUNT_
                 AND K1.WORKING_DATE <= WD_BEGIN_) X
       WHERE K.WORKING_DATE = X.WORKING_DATE
         AND K.G_ACCOUNT = G_ACCOUNT_;
    END IF;
    RETURN NVL(RESULT, 0.0000);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0.0000;
  END;

   /*ФУНКЦИЯ ВОЗВРАЩАЕТ ИСХОДЯЩИЙ ОСТАТОК ПО СЧЕТУ*/
  /*Серик (весна 2011)*/
  FUNCTION GET_ACCOUNT_OUTPUT
    (
    G_ACCOUNT_ IN INTEGER,
    WD_BEGIN_  IN INTEGER,
    WD_END_    IN INTEGER
    )
  RETURN NUMBER
  IS
    RESULT NUMBER;
    CNT    INTEGER;
  BEGIN

    SELECT COUNT(1)
      INTO CNT
      FROM P_ACCOUNT_STATE
     WHERE G_ACCOUNT = G_ACCOUNT_
       AND WORKING_DATE >= WD_BEGIN_
       AND WORKING_DATE <= WD_END_
       AND ROWNUM < 2;

    IF CNT > 0 THEN
      SELECT K.OUTPUT
        INTO RESULT
        FROM P_ACCOUNT_STATE K,
             (SELECT MIN(K1.WORKING_DATE) AS WORKING_DATE
                FROM P_ACCOUNT_STATE K1
               WHERE K1.G_ACCOUNT = G_ACCOUNT_
                 AND K1.WORKING_DATE >= WD_BEGIN_
                 AND K1.WORKING_DATE <= WD_END_) X
       WHERE K.WORKING_DATE = X.WORKING_DATE
         AND K.G_ACCOUNT = G_ACCOUNT_;

    ELSE
      SELECT K.OUTPUT
        INTO RESULT
        FROM P_ACCOUNT_STATE K,
             (SELECT MAX(K1.WORKING_DATE) AS WORKING_DATE
                FROM P_ACCOUNT_STATE K1
               WHERE K1.G_ACCOUNT = G_ACCOUNT_
                 AND K1.WORKING_DATE <= WD_BEGIN_) X
       WHERE K.WORKING_DATE = X.WORKING_DATE
         AND K.G_ACCOUNT = G_ACCOUNT_;

    END IF;
    RETURN NVL(RESULT, 0.0000);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0.0000;
  END;

   /*ФУНКЦИЯ ВОЗВРАЩАЕТ ИСХОДЯЩИЙ ОСТАТОК ПО СЧЕТУ УЕ*/
  /*Серик (весна 2011)*/
  FUNCTION GET_ACCOUNT_OUTPUT_CU
    (
    G_ACCOUNT_ IN INTEGER,
    WD_BEGIN_  IN INTEGER,
    WD_END_    IN INTEGER
    )
  RETURN NUMBER
  IS
    RESULT NUMBER;
    CNT    INTEGER;
    WORKING_DATE_ NUMBER;
  BEGIN

    SELECT COUNT(1)
      INTO CNT
      FROM P_ACCOUNT_STATE
     WHERE G_ACCOUNT = G_ACCOUNT_
       AND WORKING_DATE >= WD_BEGIN_
       AND WORKING_DATE <= WD_END_
       AND ROWNUM < 2;

    IF CNT > 0 THEN
      SELECT MIN(K1.WORKING_DATE) AS WORKING_DATE
        INTO WORKING_DATE_
        FROM P_ACCOUNT_STATE K1
       WHERE K1.G_ACCOUNT = G_ACCOUNT_
         AND K1.WORKING_DATE >= WD_BEGIN_
         AND K1.WORKING_DATE <= WD_END_;

      SELECT K.OUTPUT_CU
        INTO RESULT
        FROM P_ACCOUNT_STATE K
       WHERE K.WORKING_DATE = WORKING_DATE_
         AND K.G_ACCOUNT = G_ACCOUNT_;

    ELSE
      SELECT MAX(K1.WORKING_DATE) AS WORKING_DATE
        INTO WORKING_DATE_
        FROM P_ACCOUNT_STATE K1
       WHERE K1.G_ACCOUNT = G_ACCOUNT_
         AND K1.WORKING_DATE <= WD_BEGIN_;

      SELECT K.OUTPUT_CU
        INTO RESULT
        FROM P_ACCOUNT_STATE K
       WHERE K.WORKING_DATE = WORKING_DATE_
         AND K.G_ACCOUNT = G_ACCOUNT_;
    END IF;
    RETURN NVL(RESULT, 0.0000);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0.0000;
  END;

   /*ФУНКЦИЯ ВОЗВРАЩАЕТ ДЕБЕТОВЫЕ ОБОРОТЫ ПО СЧЕТУ*/
  /*Серик (весна 2011)*/
  FUNCTION GET_ACCOUNT_TURN_DEBET
    (
    G_ACCOUNT_ IN INTEGER,
    WD_BEGIN_  IN INTEGER,
    WD_END_    IN INTEGER
    )
  RETURN NUMBER
  IS
    RESULT NUMBER;
  BEGIN
    SELECT SUM(TURN_DEBET)
      INTO RESULT
      FROM P_ACCOUNT_STATE
     WHERE WORKING_DATE BETWEEN WD_BEGIN_ AND WD_END_
       AND G_ACCOUNT = G_ACCOUNT_;

    RETURN NVL(RESULT, 0);
  END;

  /*ФУНКЦИЯ ВОЗВРАЩАЕТ КРЕДИТОВЫЕ ОБОРОТЫ ПО СЧЕТУ*/
  FUNCTION GET_ACCOUNT_TURN_CREDIT
    (
    G_ACCOUNT_ IN INTEGER,
    WD_BEGIN_  IN INTEGER,
    WD_END_    IN INTEGER
    )
  RETURN NUMBER
  IS
    RESULT NUMBER;
  BEGIN
    SELECT SUM(TURN_CREDIT)
      INTO RESULT
      FROM P_ACCOUNT_STATE
     WHERE WORKING_DATE BETWEEN WD_BEGIN_ AND WD_END_
       AND G_ACCOUNT = G_ACCOUNT_;

    RETURN NVL(RESULT, 0);
  END;

   /*ФУНКЦИЯ ВОЗВРАЩАЕТ ДЕБЕТОВЫЕ ОБОРОТЫ ПО СЧЕТУ УЕ*/
  /*Серик (весна 2011)*/
  FUNCTION GET_ACCOUNT_TURN_DEBET_CU
    (
    G_ACCOUNT_ IN INTEGER,
    WD_BEGIN_  IN INTEGER,
    WD_END_    IN INTEGER
    )
  RETURN NUMBER
  IS
    RESULT NUMBER;
  BEGIN
    SELECT SUM(TURN_DEBET_CU)
      INTO RESULT
      FROM P_ACCOUNT_STATE
     WHERE WORKING_DATE BETWEEN WD_BEGIN_ AND WD_END_
       AND G_ACCOUNT = G_ACCOUNT_;

    RETURN NVL(RESULT, 0);
  END;

  /*ФУНКЦИЯ ВОЗВРАЩАЕТ КРЕДИТОВЫЕ ОБОРОТЫ ПО СЧЕТУ УЕ*/
  FUNCTION GET_ACCOUNT_TURN_CREDIT_CU
    (
    G_ACCOUNT_ IN INTEGER,
    WD_BEGIN_  IN INTEGER,
    WD_END_    IN INTEGER
    )
  RETURN NUMBER
  IS
    RESULT NUMBER;
  BEGIN
    SELECT SUM(TURN_CREDIT_CU)
      INTO RESULT
      FROM P_ACCOUNT_STATE
     WHERE WORKING_DATE BETWEEN WD_BEGIN_ AND WD_END_
      AND G_ACCOUNT = G_ACCOUNT_;

    RETURN NVL(RESULT, 0);
  END;


  /*ФУНКЦИЯ ВОЗВРАЩАЕТ СУММУ СПИСАНИЯ ДУИОПА ЗАЯВЛЕНИЯ НА ПЕРЕВОД*/
  FUNCTION GET_CLAIM_TRANSFER_SUMM_SPIS
    (
    P_CLAIM_TRANSFER_ IN NUMBER
    )
  RETURN NUMBER
  IS
    RESULT NUMBER;
    -- Тима(11.05.2011): Для вычисления значения колонки в гриде "Обработки реестров фронт-офиса"
  BEGIN
        SELECT SUM(R.SUMMA)
          INTO RESULT
          FROM P_LT_OPR_CLAIM L,
               P_OPR R,
               P_G_OPRKND K,
               WORKING_DATE W
         WHERE L.P_CLAIM_TRANSFER = P_CLAIM_TRANSFER_ AND
               R.P_OPR = L.P_OPR AND
               R.P_G_OPRKND = K.P_G_OPRKND AND
               K.P_G_GROUP_OPRKND IN (8, 103, 102) AND
               R.WORKING_DATE = W.WORKING_DATE AND
               W.WORK_DATE = ( SELECT MAX(W2.WORK_DATE)
                                 FROM P_LT_OPR_CLAIM L2,
                                      P_OPR R2,
                                      WORKING_DATE W2
                                WHERE L2.P_CLAIM_TRANSFER = P_CLAIM_TRANSFER_ AND
                                      R2.P_OPR = L2.P_OPR AND
                                      R2.WORKING_DATE = W2.WORKING_DATE
                             );

    RETURN NVL(RESULT, 0);
  END;

  /*ФУНКЦИЯ ВОЗВРАЩАЕТ ДАТУ СПИСАНИЯ ДУИОПА ЗАЯВЛЕНИЯ НА ПЕРЕВОД*/
  FUNCTION GET_CLAIM_TRANSFER_DATE_SPIS
    (
    P_CLAIM_TRANSFER_ IN NUMBER
    )
  RETURN DATE
  IS
    RESULT DATE;
    -- Тима(11.05.2011): Для вычисления значения колонки в гриде "Обработки реестров фронт-офиса"
  BEGIN
       SELECT MAX(W2.WORK_DATE)
         INTO RESULT
         FROM P_LT_OPR_CLAIM L2,
              P_OPR R2,
              WORKING_DATE W2
        WHERE L2.P_CLAIM_TRANSFER = P_CLAIM_TRANSFER_ AND
              R2.P_OPR = L2.P_OPR AND
              R2.WORKING_DATE = W2.WORKING_DATE;

    RETURN(RESULT);
  END;

  /*ФУНКЦИЯ ВОЗВРАЩАЕТ СУММУ СПИСАНИЯ ДУИОПА ЗАЯВЛЕНИЯ НА ВЫПЛАТУ*/
  FUNCTION GET_CLAIM_PAY_OUT_SUMM_SPIS
    (
    P_CLAIM_PAY_OUT_ IN NUMBER
    )
  RETURN NUMBER
  IS
    CNT_           NUMBER := 0;
    P_ADD_SHEET_   P_CLAIM_PAY_OUT.P_CLAIM_PAY_OUT%TYPE := P_CLAIM_PAY_OUT_;
    RESULT NUMBER;
    -- Темеков А.А. (16.05.2011): Для вычисления значения колонки в гриде "Заявления", модуля Клиенты
  BEGIN
        /*SELECT SUM(R.SUMMA)
          INTO RESULT
          FROM P_LT_OPR_CLAIM L,
               P_OPR R,
               WORKING_DATE W
         WHERE L.P_CLAIM_PAY_OUT = P_CLAIM_PAY_OUT_ AND
               R.P_OPR = L.P_OPR AND
               R.WORKING_DATE = W.WORKING_DATE AND
               W.WORK_DATE = ( SELECT MAX(W2.WORK_DATE)
                                 FROM P_LT_OPR_CLAIM L2,
                                      P_OPR R2,
                                      WORKING_DATE W2
                                WHERE L2.P_CLAIM_PAY_OUT = P_CLAIM_PAY_OUT_ AND
                                      R2.P_OPR = L2.P_OPR AND
                                      R2.WORKING_DATE = W2.WORKING_DATE
                             );*/

        -- ЕСЛИ ИМЕЕТСЯ ДОП.СОГЛАШЕНИЕ ТО ИЩЕМ ПО НЕМУ
        SELECT COUNT(*)
          INTO CNT_
          FROM P_CLAIM_PAY_OUT T
         WHERE T.P_CLAIM_PAY_OUT_INITIAL = P_CLAIM_PAY_OUT_
           AND T.P_G_CLAIM_PAY_OUT_KND = 4;

        IF CNT_ > 0 THEN
          BEGIN
            SELECT T.P_CLAIM_PAY_OUT
              INTO P_ADD_SHEET_
              FROM P_CLAIM_PAY_OUT T
             WHERE T.P_CLAIM_PAY_OUT_INITIAL = P_CLAIM_PAY_OUT_
               AND T.P_G_CLAIM_PAY_OUT_KND = 4;
          EXCEPTION
              -- ПО РЕЗУЛЬТАТАМ МИГРАЦИИ, ОШИБОЧНО НЕКОТОРЫЕ ДОП.СОГЛАШЕНИЯ
              -- ССЫЛАЮТСЯ НА ОДНО ЗАЯВЛЕНИЕ, ПОЭТОМУ БУДУ БРАТЬ ТОЛЬКО АКТИВНЫЕ
              WHEN TOO_MANY_ROWS THEN
                  BEGIN
                    SELECT T.P_CLAIM_PAY_OUT
                      INTO P_ADD_SHEET_
                      FROM P_CLAIM_PAY_OUT T
                     WHERE T.P_CLAIM_PAY_OUT_INITIAL = P_CLAIM_PAY_OUT_
                       AND T.P_G_CLAIM_PAY_OUT_KND = 4
                       AND T.IS_ACTIVE = 1;
                  EXCEPTION
                    -- ВДРУГ ВСЕ ДОПИКИ ЗАКРЫТЫ, ТОГДА БУДУ БРАТЬ ПЕРВЫЙ ПОПАВШИЙСЯ
                    WHEN NO_DATA_FOUND THEN
                      SELECT T.P_CLAIM_PAY_OUT
                        INTO P_ADD_SHEET_
                        FROM P_CLAIM_PAY_OUT T
                       WHERE T.P_CLAIM_PAY_OUT_INITIAL = P_CLAIM_PAY_OUT_
                         AND T.P_G_CLAIM_PAY_OUT_KND = 4
                         AND ROWNUM = 1;
                  END;
          END;
        END IF;

        SELECT SUM(PP.SUM_PAY)
          INTO RESULT
          FROM P_PAYMENT_INFO PP
         WHERE PP.P_CLAIM_PAY_OUT = P_ADD_SHEET_;

     RETURN NVL(RESULT, 0);
  END;

  /*ФУНКЦИЯ ВОЗВРАЩАЕТ ДАТУ СПИСАНИЯ ДУИОПА ЗАЯВЛЕНИЯ НА ВЫПЛАТУ*/
  FUNCTION GET_CLAIM_PAY_OUT_DATE_SPIS
    (
    P_CLAIM_PAY_OUT_ IN NUMBER
    )
  RETURN DATE
  IS
    -- Темеков А.А. (16.05.2011): Для вычисления значения колонки в гриде "Заявления", модуля Клиенты
    -- отражаю всегда самую первую выплату, если будет частичная выплата - будут смотреть по графику
    RESULT DATE;
    CNT_           NUMBER := 0;
    P_ADD_SHEET_   P_CLAIM_PAY_OUT.P_CLAIM_PAY_OUT%TYPE := P_CLAIM_PAY_OUT_;
  BEGIN
      -- ЕСЛИ ИМЕЕТСЯ ДОП.СОГЛАШЕНИЕ ТО ИЩЕМ ПО НЕМУ
      SELECT COUNT(*)
        INTO CNT_
        FROM P_CLAIM_PAY_OUT T
       WHERE T.P_CLAIM_PAY_OUT_INITIAL = P_CLAIM_PAY_OUT_
         AND T.P_G_CLAIM_PAY_OUT_KND = 4;

      IF CNT_ > 0 THEN
          BEGIN
            SELECT T.P_CLAIM_PAY_OUT
              INTO P_ADD_SHEET_
              FROM P_CLAIM_PAY_OUT T
             WHERE T.P_CLAIM_PAY_OUT_INITIAL = P_CLAIM_PAY_OUT_
               AND T.P_G_CLAIM_PAY_OUT_KND = 4;
          EXCEPTION
              -- ПО РЕЗУЛЬТАТАМ МИГРАЦИИ, ОШИБОЧНО НЕКОТОРЫЕ ДОП.СОГЛАШЕНИЯ
              -- ССЫЛАЮТСЯ НА ОДНО ЗАЯВЛЕНИЕ, ПОЭТОМУ БУДУ БРАТЬ ТОЛЬКО АКТИВНЫЕ
              WHEN TOO_MANY_ROWS THEN
                  BEGIN
                    SELECT T.P_CLAIM_PAY_OUT
                      INTO P_ADD_SHEET_
                      FROM P_CLAIM_PAY_OUT T
                     WHERE T.P_CLAIM_PAY_OUT_INITIAL = P_CLAIM_PAY_OUT_
                       AND T.P_G_CLAIM_PAY_OUT_KND = 4
                       AND T.IS_ACTIVE = 1;
                  EXCEPTION
                    -- ВДРУГ ВСЕ ДОПИКИ ЗАКРЫТЫ, ТОГДА БУДУ БРАТЬ ПЕРВЫЙ ПОПАВШИЙСЯ
                    WHEN NO_DATA_FOUND THEN
                      SELECT T.P_CLAIM_PAY_OUT
                        INTO P_ADD_SHEET_
                        FROM P_CLAIM_PAY_OUT T
                       WHERE T.P_CLAIM_PAY_OUT_INITIAL = P_CLAIM_PAY_OUT_
                         AND T.P_G_CLAIM_PAY_OUT_KND = 4
                         AND ROWNUM = 1;
                  END;
          END;
      END IF;

      SELECT MIN(W2.WORK_DATE)
        INTO RESULT
        FROM P_LT_OPR_CLAIM L2,
             P_OPR R2,
             WORKING_DATE W2
       WHERE L2.P_CLAIM_PAY_OUT = P_ADD_SHEET_ AND
             R2.P_OPR = L2.P_OPR AND
             R2.WORKING_DATE = W2.WORKING_DATE;

    RETURN(RESULT);
  END;

  /*ФУНКЦИЯ ВОЗВРАЩАЕТ СУММУ СПИСАНИЯ ДУИОПА ЗАЯВЛЕНИЯ НА ПЕРЕВОД МЕЖДУ ПОРТФЕЛЯМИ*/
  FUNCTION GET_CLAIM_TRANS_PRTF_SUMM_SPIS
    (
    P_CLAIM_TRANS_PRTF_ IN NUMBER
    )
  RETURN NUMBER
  IS
    RESULT NUMBER;
    -- Тима(11.05.2011): Для вычисления значения колонки в гриде "Обработки реестров фронт-офиса"
  BEGIN
        SELECT SUM(R.SUMMA)
          INTO RESULT
          FROM P_LT_OPR_CLAIM L,
               P_OPR R,
               WORKING_DATE W
         WHERE L.P_CLAIM_TRANS_PRTF = P_CLAIM_TRANS_PRTF_ AND
               R.P_OPR = L.P_OPR AND
               R.WORKING_DATE = W.WORKING_DATE AND
               W.WORK_DATE = ( SELECT MAX(W2.WORK_DATE)
                                 FROM P_LT_OPR_CLAIM L2,
                                      P_OPR R2,
                                      WORKING_DATE W2
                                WHERE L2.P_CLAIM_TRANS_PRTF = P_CLAIM_TRANS_PRTF_ AND
                                      R2.P_OPR = L2.P_OPR AND
                                      R2.WORKING_DATE = W2.WORKING_DATE
                             );

    RETURN NVL(RESULT, 0);
  END;

  /*ФУНКЦИЯ ВОЗВРАЩАЕТ ДАТУ СПИСАНИЯ ДУИОПА ЗАЯВЛЕНИЯ НА ПЕРЕВОД*/
  FUNCTION GET_CLAIM_TRANS_PRTF_DATE_SPIS
    (
    P_CLAIM_TRANS_PRTF_ IN NUMBER
    )
  RETURN DATE
  IS
    RESULT DATE;
    -- Тима(11.05.2011): Для вычисления значения колонки в гриде "Обработки реестров фронт-офиса"
  BEGIN
       SELECT MAX(W2.WORK_DATE)
         INTO RESULT
         FROM P_LT_OPR_CLAIM L2,
              P_OPR R2,
              WORKING_DATE W2
        WHERE L2.P_CLAIM_TRANS_PRTF = P_CLAIM_TRANS_PRTF_ AND
              R2.P_OPR = L2.P_OPR AND
              R2.WORKING_DATE = W2.WORKING_DATE;

    RETURN(RESULT);
  END;

  FUNCTION GET_INPUT_TRANSFER_IN_PERIOD
  (
    P_CONTRACT_ IN NUMBER,
    DATE_BEGIN_ IN DATE,
    DATE_END_   IN DATE
  )
  RETURN NUMBER
  -- Тима(04,08,2011): функция возвращает сумму входящих переводов из др.НПФ
  IS
    RESULT NUMBER;
  BEGIN

       SELECT SUM(O.SUMMA)
         INTO RESULT
         FROM P_CONTRACT P,
              P_OPR O,
              P_G_OPRKND K,
              WORKING_DATE W
        WHERE P.P_CONTRACT = P_CONTRACT_ AND
              --P.P_G_CONTRACT_KND IN (1,10) AND
              O.P_CONTRACT = P.P_CONTRACT AND
              O.P_G_OPRKND = K.P_G_OPRKND  AND
              K.P_G_GROUP_OPRKND = 33 AND
              O.WORKING_DATE = W.WORKING_DATE AND
              W.WORK_DATE BETWEEN DATE_BEGIN_ AND DATE_END_;

    RETURN NVL(RESULT,0);

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION GET_OUTPUT_TRANSFER_IN_PERIOD
  (
    P_CONTRACT_ IN NUMBER,
    DATE_BEGIN_ IN DATE,
    DATE_END_   IN DATE
  )
  RETURN NUMBER
  -- Тима(04,08,2011): функция возвращает сумму исходящих переводов из др.НПФ
  IS
    RESULT NUMBER;
  BEGIN

       SELECT SUM(O.SUMMA)
         INTO RESULT
         FROM P_CONTRACT P,
              P_OPR O,
              P_G_OPRKND K,
              WORKING_DATE W
        WHERE P.P_CONTRACT = P_CONTRACT_ AND
              --P.P_G_CONTRACT_KND IN (1,10) AND
              O.P_CONTRACT = P.P_CONTRACT AND
              O.P_G_OPRKND = K.P_G_OPRKND  AND
              K.P_G_GROUP_OPRKND = 8 AND
              O.WORKING_DATE = W.WORKING_DATE AND
              W.WORK_DATE BETWEEN DATE_BEGIN_ AND DATE_END_;

    RETURN RESULT;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION GET_PAY_DATE
  (
    G_PERSON_ IN NUMBER,
    NUM_      IN NUMBER
  )
  RETURN DATE
  -- Тима(12.08.2011): функция возвращает дату третей выплаты произведеной по вкладчику
  IS
    RESULT DATE;
  BEGIN

       -- ищем дату третей выплаты
       SELECT WORK_DATE
         INTO RESULT
         FROM (SELECT WORK_DATE,
                      ROWNUM AS NUM -- ПОЛЕ ROWNUM НАДО КАК-ТО ОБОЗВАТЬ, А ТО WHERE ROWNUM=3 НИЧЕГО НЕ ВЫТАСКИВАЕТ
                 FROM (
                       SELECT W.WORK_DATE
                         FROM P_CONTRACT P,
                              P_OPR O,
                              P_G_OPRKND K,
                              WORKING_DATE W
                        WHERE P.G_PERSON_RECIPIENT = G_PERSON_ AND
                              P.P_G_CONTRACT_KND IN (1,10) AND
                              O.P_CONTRACT = P.P_CONTRACT AND
                              O.P_G_OPRKND = K.P_G_OPRKND  AND
                              K.P_G_GROUP_OPRKND IN (8,9,102,103)  AND
                              O.WORKING_DATE = W.WORKING_DATE AND
                              -- ОТСЕКАЮ СТОРНО
                              NOT EXISTS ( SELECT 1
                                             FROM P_OPR O2
                                            WHERE O2.P_OPR_STORNO = O.P_OPR)
                        ORDER BY O.P_OPR
                      )
              ) SL
        WHERE NUM = NUM_
           ;

    RETURN RESULT;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION GET_PAY_REASON
  (
    G_PERSON_ IN NUMBER,
    NUM_      IN NUMBER
  )
  RETURN VARCHAR2
  -- Тима(22,07,2011): функция возвращает причину выплаты произведеной по вкладчику
  IS
    RESULT VARCHAR2(200);
    P_CLAIM_PAY_OUT_ NUMBER;
    CLAIM_ NUMBER;
    P_G_CLAIM_TRANSFER_KND_ NUMBER;
    P_G_GROUP_OPRKND_       NUMBER;
  BEGIN

       -- ДОСТАЕМ ЗАЯВЛЕНИЕ С КОТОРОГО ПРОИЗВОДИЛАСЬ ВЫПЛАТА
       SELECT P_CLAIM_PAY_OUT,
              CLAIM,
              P_G_CLAIM_TRANSFER_KND,
              P_G_GROUP_OPRKND
         INTO P_CLAIM_PAY_OUT_,
              CLAIM_,
              P_G_CLAIM_TRANSFER_KND_,
              P_G_GROUP_OPRKND_
         FROM (SELECT P_CLAIM_PAY_OUT,
                      CLAIM,
                      P_G_CLAIM_TRANSFER_KND,
                      P_G_GROUP_OPRKND,
                      ROWNUM AS NUM -- ПОЛЕ ROWNUM НАДО КАК-ТО ОБОЗВАТЬ, А ТО WHERE ROWNUM=3 НИЧЕГО НЕ ВЫТАСКИВАЕТ
                 FROM (
                       SELECT C.P_CLAIM_PAY_OUT,
                              1 CLAIM,
                              NULL AS P_G_CLAIM_TRANSFER_KND,
                              O.P_OPR,
                              O.WORKING_DATE,
                              K.P_G_GROUP_OPRKND
                         FROM P_CLAIM_PAY_OUT C,
                              P_LT_OPR_CLAIM L,
                              P_CONTRACT P,
                              P_OPR O,
                              P_G_OPRKND K
                        WHERE C.P_CONTRACT = P.P_CONTRACT AND
                              L.P_OPR = O.P_OPR AND
                              L.P_CLAIM_PAY_OUT = C.P_CLAIM_PAY_OUT AND
                              P.G_PERSON_RECIPIENT = G_PERSON_ AND
                              P.P_G_CONTRACT_KND IN (1,10) AND
                              O.P_CONTRACT = P.P_CONTRACT AND
                              O.P_G_OPRKND = K.P_G_OPRKND  AND
                              K.P_G_GROUP_OPRKND = 9 AND
                              -- ОТСЕКАЮ СТОРНО
                              NOT EXISTS ( SELECT 1
                                             FROM P_OPR O2
                                            WHERE O2.P_OPR_STORNO = O.P_OPR)
                       UNION
                       SELECT NULL P_CLAIM_TRANSFER,
                              2 CLAIM,
                              NULL P_G_CLAIM_TRANSFER_KND,
                              O.P_OPR,
                              O.WORKING_DATE,
                              K.P_G_GROUP_OPRKND
                         FROM --P_CLAIM_TRANSFER C,
                              --P_LT_OPR_CLAIM L,
                              P_CONTRACT P,
                              P_OPR O,
                              P_G_OPRKND K
                        WHERE --C.P_CONTRACT = P.P_CONTRACT AND
                              --L.P_OPR = O.P_OPR AND
                              --L.P_CLAIM_TRANSFER = C.P_CLAIM_TRANSFER AND
                              P.G_PERSON_RECIPIENT = G_PERSON_ AND
                              P.P_G_CONTRACT_KND IN (1,10) AND
                              O.P_CONTRACT = P.P_CONTRACT AND
                              O.P_G_OPRKND = K.P_G_OPRKND  AND
                              K.P_G_GROUP_OPRKND IN (8,102,103) AND
                              -- ОТСЕКАЮ СТОРНО
                              NOT EXISTS ( SELECT 1
                                             FROM P_OPR O2
                                            WHERE O2.P_OPR_STORNO = O.P_OPR)
                        ORDER BY WORKING_DATE, P_OPR
                      )
              ) SL
        WHERE NUM = NUM_;


       IF CLAIM_ = 1 THEN
           SELECT R.P_G_REASON_PAY
             INTO RESULT
             FROM P_G_LT_REASON_PAY LT,
                  P_G_REASON_PAY R,
                  P_CLAIM_PAY_OUT C
            WHERE C.P_CLAIM_PAY_OUT = P_CLAIM_PAY_OUT_ AND
                  LT.P_G_PAY_OUT_SUB_TYPE = C.P_G_PAY_OUT_SUB_TYPE AND
                  LT.P_G_REASON_PAY = R.P_G_REASON_PAY;
       ELSIF CLAIM_ = 2 THEN
         IF P_G_GROUP_OPRKND_ IN (102,103) THEN
           RESULT := 7;
         ELSE
           RESULT := 6;
         END IF;
       ELSE
         RESULT := NULL;
       END IF;

    RETURN RESULT;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN NULL;

       /*
       SELECT COUNT(1)
         INTO CLAIM_
         FROM P_CONTRACT P,
              P_OPR O,
              P_G_OPRKND K
        WHERE P.G_PERSON_RECIPIENT = G_PERSON_ AND
              P.P_G_CONTRACT_KND IN (1,10) AND
              O.P_CONTRACT = P.P_CONTRACT AND
              O.P_G_OPRKND = K.P_G_OPRKND  AND
              K.P_G_GROUP_OPRKND IN (9,8);
       IF CLAIM_ > 0 THEN
         RETURN 1;
       ELSE
         RETURN NULL;
       END IF;
       */
    WHEN OTHERS THEN
      RETURN NULL;
  END;


  FUNCTION GET_FIRST_PAY_DATE
  (
    G_PERSON_ IN NUMBER
  )
  RETURN DATE
  -- Тима(22,07,2011): функция возвращает дату первой выплаты произведеной по вкладчику
  IS
    RESULT DATE;
  BEGIN

       SELECT MIN(W.WORK_DATE)
         INTO RESULT
         FROM P_CLAIM_PAY_OUT C,
              P_CONTRACT P,
              P_OPR O,
              P_G_OPRKND K,
              WORKING_DATE W
        WHERE C.P_CONTRACT = P.P_CONTRACT AND
              P.G_PERSON_RECIPIENT = G_PERSON_ AND
              P.P_G_CONTRACT_KND IN (1,10) AND
              O.P_CONTRACT = P.P_CONTRACT AND
              O.P_G_OPRKND = K.P_G_OPRKND  AND
              K.P_G_GROUP_OPRKND = 9  AND
              O.WORKING_DATE = W.WORKING_DATE;

    RETURN RESULT;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION GET_FIRST_PAY_REASON
  (
    G_PERSON_ IN NUMBER
  )
  RETURN VARCHAR2
  -- Тима(22,07,2011): функция возвращает причину первой выплаты произведеной по вкладчику
  IS
    RESULT VARCHAR2(200);
    P_CLAIM_PAY_OUT_ NUMBER;
  BEGIN

       -- ДОСТАЕМ САМОЕ РАННЕЕ ЗАЯВЛЕНИЕ С КОТОРОГО ПРОИЗВОДИЛАСЬ ВЫПЛАТА
       SELECT MIN(C.P_CLAIM_PAY_OUT)
         INTO P_CLAIM_PAY_OUT_
         FROM P_CLAIM_PAY_OUT C,
              P_CONTRACT P,
              P_OPR O,
              P_G_OPRKND K,
              WORKING_DATE W
        WHERE C.P_CONTRACT = P.P_CONTRACT AND
              P.G_PERSON_RECIPIENT = G_PERSON_ AND
              P.P_G_CONTRACT_KND IN (1,10) AND
              O.P_CONTRACT = P.P_CONTRACT AND
              O.P_G_OPRKND = K.P_G_OPRKND  AND
              K.P_G_GROUP_OPRKND = 9  AND
              O.WORKING_DATE = W.WORKING_DATE AND
              W.WORK_DATE = (  SELECT MIN(W2.WORK_DATE)
                                 FROM P_CLAIM_PAY_OUT C2,
                                      P_CONTRACT P2,
                                      P_OPR O2,
                                      P_G_OPRKND K2,
                                      WORKING_DATE W2
                                WHERE C2.P_CONTRACT = P2.P_CONTRACT AND
                                      P2.G_PERSON_RECIPIENT = G_PERSON_ AND
                                      P2.P_G_CONTRACT_KND IN (1,10) AND
                                      O2.P_CONTRACT = P2.P_CONTRACT AND
                                      O2.P_G_OPRKND = K2.P_G_OPRKND  AND
                                      K2.P_G_GROUP_OPRKND = 9  AND
                                      O2.WORKING_DATE = W2.WORKING_DATE
                            );

       SELECT --R.NAME
              R.P_G_REASON_PAY
         INTO RESULT
         FROM P_G_LT_REASON_PAY LT,
              P_G_REASON_PAY R,
              P_CLAIM_PAY_OUT C
        WHERE C.P_CLAIM_PAY_OUT = P_CLAIM_PAY_OUT_ AND
              LT.P_G_PAY_OUT_SUB_TYPE = C.P_G_PAY_OUT_SUB_TYPE AND
              LT.P_G_REASON_PAY = R.P_G_REASON_PAY;

    RETURN RESULT;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;


  FUNCTION GET_FIRST_PAY_SUMM
  (
    G_PERSON_ IN NUMBER
  )
  RETURN NUMBER
  -- Тима(22,07,2011): функция возвращает сумму первой выплаты произведеной по вкладчику
  IS
    RESULT NUMBER;
  BEGIN

       -- ДОСТАЕМ САМОЕ РАННЕЕ ЗАЯВЛЕНИЕ С КОТОРОГО ПРОИЗВОДИЛАСЬ ВЫПЛАТА
       SELECT SUM(O.SUMMA)
         INTO RESULT
         FROM P_CLAIM_PAY_OUT C,
              P_CONTRACT P,
              P_OPR O,
              P_G_OPRKND K,
              WORKING_DATE W
        WHERE C.P_CONTRACT = P.P_CONTRACT AND
              P.G_PERSON_RECIPIENT = G_PERSON_ AND
              P.P_G_CONTRACT_KND IN (1,10) AND
              O.P_CONTRACT = P.P_CONTRACT AND
              O.P_G_OPRKND = K.P_G_OPRKND  AND
              K.P_G_GROUP_OPRKND = 9  AND
              O.WORKING_DATE = W.WORKING_DATE AND
              W.WORK_DATE = (  SELECT MIN(W2.WORK_DATE)
                                 FROM P_CLAIM_PAY_OUT C2,
                                      P_CONTRACT P2,
                                      P_OPR O2,
                                      P_G_OPRKND K2,
                                      WORKING_DATE W2
                                WHERE C2.P_CONTRACT = P2.P_CONTRACT AND
                                      P2.G_PERSON_RECIPIENT = G_PERSON_ AND
                                      P2.P_G_CONTRACT_KND IN (1,10) AND
                                      O2.P_CONTRACT = P2.P_CONTRACT AND
                                      O2.P_G_OPRKND = K2.P_G_OPRKND  AND
                                      K2.P_G_GROUP_OPRKND = 9  AND
                                      O2.WORKING_DATE = W2.WORKING_DATE
                            );

    RETURN RESULT;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  FUNCTION GET_SECOND_PAY_DATE
  (
    G_PERSON_ IN NUMBER
  )
  RETURN DATE
  -- Тима(12.08.2011): функция возвращает дату второй выплаты произведеной по вкладчику
  IS
    RESULT DATE;
    DATE_  DATE;
  BEGIN

       -- ищем дату первой выплаты
       SELECT MIN(W.WORK_DATE)
         INTO DATE_
         FROM P_CLAIM_PAY_OUT C,
              P_CONTRACT P,
              P_OPR O,
              P_G_OPRKND K,
              WORKING_DATE W
        WHERE C.P_CONTRACT = P.P_CONTRACT AND
              P.G_PERSON_RECIPIENT = G_PERSON_ AND
              P.P_G_CONTRACT_KND IN (1,10) AND
              O.P_CONTRACT = P.P_CONTRACT AND
              O.P_G_OPRKND = K.P_G_OPRKND  AND
              K.P_G_GROUP_OPRKND = 9  AND
              O.WORKING_DATE = W.WORKING_DATE;

       -- ищем следующую дату выплаты после первой - это будет вторая выплата
       SELECT MIN(W.WORK_DATE)
         INTO RESULT
         FROM P_CLAIM_PAY_OUT C,
              P_CONTRACT P,
              P_OPR O,
              P_G_OPRKND K,
              WORKING_DATE W
        WHERE C.P_CONTRACT = P.P_CONTRACT AND
              P.G_PERSON_RECIPIENT = G_PERSON_ AND
              P.P_G_CONTRACT_KND IN (1,10) AND
              O.P_CONTRACT = P.P_CONTRACT AND
              O.P_G_OPRKND = K.P_G_OPRKND  AND
              K.P_G_GROUP_OPRKND = 9  AND
              O.WORKING_DATE = W.WORKING_DATE AND
              W.WORK_DATE > DATE_;

    RETURN RESULT;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION GET_SECOND_PAY_REASON
  (
    G_PERSON_ IN NUMBER
  )
  RETURN VARCHAR2
  -- Тима(12.08.2011): функция возвращает причину второй выплаты произведеной по вкладчику
  IS
    RESULT VARCHAR2(100);
    P_CLAIM_PAY_OUT_ NUMBER;
    DATE_            DATE;
  BEGIN

       DATE_ := GET_SECOND_PAY_DATE(G_PERSON_);

       IF DATE_ IS NOT NULL THEN
           -- ДОСТАЕМ САМОЕ РАННЕЕ ЗАЯВЛЕНИЕ С КОТОРОГО ПРОИЗВОДИЛАСЬ ВЫПЛАТА
           SELECT MIN(C.P_CLAIM_PAY_OUT)
             INTO P_CLAIM_PAY_OUT_
             FROM P_CLAIM_PAY_OUT C,
                  P_CONTRACT P,
                  P_OPR O,
                  P_G_OPRKND K,
                  WORKING_DATE W
            WHERE C.P_CONTRACT = P.P_CONTRACT AND
                  P.G_PERSON_RECIPIENT = G_PERSON_ AND
                  P.P_G_CONTRACT_KND IN (1,10) AND
                  O.P_CONTRACT = P.P_CONTRACT AND
                  O.P_G_OPRKND = K.P_G_OPRKND  AND
                  K.P_G_GROUP_OPRKND = 9  AND
                  O.WORKING_DATE = W.WORKING_DATE AND
                  W.WORK_DATE = (  SELECT MAX(W2.WORK_DATE)
                                     FROM P_CLAIM_PAY_OUT C2,
                                          P_CONTRACT P2,
                                          P_OPR O2,
                                          P_G_OPRKND K2,
                                          WORKING_DATE W2
                                    WHERE C2.P_CONTRACT = P2.P_CONTRACT AND
                                          P2.G_PERSON_RECIPIENT = G_PERSON_ AND
                                          P2.P_G_CONTRACT_KND IN (1,10) AND
                                          O2.P_CONTRACT = P2.P_CONTRACT AND
                                          O2.P_G_OPRKND = K2.P_G_OPRKND  AND
                                          K2.P_G_GROUP_OPRKND = 9  AND
                                          O2.WORKING_DATE = W2.WORKING_DATE AND
                                          W2.WORK_DATE < DATE_

                                );

           SELECT R.NAME
             INTO RESULT
             FROM P_G_LT_REASON_PAY LT,
                  P_G_REASON_PAY R,
                  P_CLAIM_PAY_OUT C
            WHERE C.P_CLAIM_PAY_OUT = P_CLAIM_PAY_OUT_ AND
                  LT.P_G_PAY_OUT_SUB_TYPE = C.P_G_PAY_OUT_SUB_TYPE AND
                  LT.P_G_REASON_PAY = R.P_G_REASON_PAY;
       END IF;

    RETURN RESULT;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION GET_SECOND_PAY_SUMM
  (
    G_PERSON_ IN NUMBER
  )
  RETURN NUMBER
  -- Тима(12.08.2011): функция возвращает сумму второй выплаты произведеной по вкладчику
  IS
    RESULT NUMBER;
    DATE_  DATE;
  BEGIN

       DATE_ := GET_SECOND_PAY_DATE(G_PERSON_);

       IF DATE_ IS NOT NULL THEN
           -- ДОСТАЕМ САМОЕ РАННЕЕ ЗАЯВЛЕНИЕ С КОТОРОГО ПРОИЗВОДИЛАСЬ ВЫПЛАТА
           SELECT SUM(O.SUMMA)
             INTO RESULT
             FROM P_CLAIM_PAY_OUT C,
                  P_CONTRACT P,
                  P_OPR O,
                  P_G_OPRKND K,
                  WORKING_DATE W
            WHERE C.P_CONTRACT = P.P_CONTRACT AND
                  P.G_PERSON_RECIPIENT = G_PERSON_ AND
                  P.P_G_CONTRACT_KND IN (1,10) AND
                  O.P_CONTRACT = P.P_CONTRACT AND
                  O.P_G_OPRKND = K.P_G_OPRKND  AND
                  K.P_G_GROUP_OPRKND = 9  AND
                  O.WORKING_DATE = W.WORKING_DATE AND
                  W.WORK_DATE = (  SELECT MAX(W2.WORK_DATE)
                                     FROM P_CLAIM_PAY_OUT C2,
                                          P_CONTRACT P2,
                                          P_OPR O2,
                                          P_G_OPRKND K2,
                                          WORKING_DATE W2
                                    WHERE C2.P_CONTRACT = P2.P_CONTRACT AND
                                          P2.G_PERSON_RECIPIENT = G_PERSON_ AND
                                          P2.P_G_CONTRACT_KND IN (1,10) AND
                                          O2.P_CONTRACT = P2.P_CONTRACT AND
                                          O2.P_G_OPRKND = K2.P_G_OPRKND  AND
                                          K2.P_G_GROUP_OPRKND = 9  AND
                                          O2.WORKING_DATE = W2.WORKING_DATE AND
                                          W2.WORK_DATE < DATE_
                                );
       END IF;

    RETURN RESULT;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;


  FUNCTION GET_THIRD_PAY_DATE
  (
    G_PERSON_ IN NUMBER
  )
  RETURN DATE
  -- Тима(12.08.2011): функция возвращает дату третей выплаты произведеной по вкладчику
  IS
    RESULT DATE;
  BEGIN

       -- ищем дату третей выплаты
       SELECT WORK_DATE
         INTO RESULT
         FROM (SELECT WORK_DATE,
                      ROWNUM AS NUM -- ПОЛЕ ROWNUM НАДО КАК-ТО ОБОЗВАТЬ, А ТО WHERE ROWNUM=3 НИЧЕГО НЕ ВЫТАСКИВАЕТ
                 FROM (
                       SELECT W.WORK_DATE
                         FROM P_CLAIM_PAY_OUT C,
                              P_CONTRACT P,
                              P_OPR O,
                              P_G_OPRKND K,
                              WORKING_DATE W
                        WHERE C.P_CONTRACT = P.P_CONTRACT AND
                              P.G_PERSON_RECIPIENT = G_PERSON_ AND
                              P.P_G_CONTRACT_KND IN (1,10) AND
                              O.P_CONTRACT = P.P_CONTRACT AND
                              O.P_G_OPRKND = K.P_G_OPRKND  AND
                              K.P_G_GROUP_OPRKND = 9  AND
                              O.WORKING_DATE = W.WORKING_DATE
                        ORDER BY W.WORKING_DATE
                      )
              ) SL
        WHERE NUM = 3
           ;

    RETURN RESULT;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION GET_THIRD_PAY_REASON
  (
    G_PERSON_ IN NUMBER
  )
  RETURN VARCHAR2
  -- Тима(12.08.2011): функция возвращает причину третей выплаты произведеной по вкладчику
  IS
    RESULT VARCHAR2(100);
    P_CLAIM_PAY_OUT_ NUMBER;
    DATE_            DATE;
  BEGIN

       DATE_ := GET_THIRD_PAY_DATE(G_PERSON_);

       IF DATE_ IS NOT NULL THEN
           -- ДОСТАЕМ САМОЕ РАННЕЕ ЗАЯВЛЕНИЕ С КОТОРОГО ПРОИЗВОДИЛАСЬ ВЫПЛАТА
           SELECT MIN(C.P_CLAIM_PAY_OUT)
             INTO P_CLAIM_PAY_OUT_
             FROM P_CLAIM_PAY_OUT C,
                  P_CONTRACT P,
                  P_OPR O,
                  P_G_OPRKND K,
                  WORKING_DATE W
            WHERE C.P_CONTRACT = P.P_CONTRACT AND
                  P.G_PERSON_RECIPIENT = G_PERSON_ AND
                  P.P_G_CONTRACT_KND IN (1,10) AND
                  O.P_CONTRACT = P.P_CONTRACT AND
                  O.P_G_OPRKND = K.P_G_OPRKND  AND
                  K.P_G_GROUP_OPRKND = 9  AND
                  O.WORKING_DATE = W.WORKING_DATE AND
                  W.WORK_DATE = (  SELECT MAX(W2.WORK_DATE)
                                     FROM P_CLAIM_PAY_OUT C2,
                                          P_CONTRACT P2,
                                          P_OPR O2,
                                          P_G_OPRKND K2,
                                          WORKING_DATE W2
                                    WHERE C2.P_CONTRACT = P2.P_CONTRACT AND
                                          P2.G_PERSON_RECIPIENT = G_PERSON_ AND
                                          P2.P_G_CONTRACT_KND IN (1,10) AND
                                          O2.P_CONTRACT = P2.P_CONTRACT AND
                                          O2.P_G_OPRKND = K2.P_G_OPRKND  AND
                                          K2.P_G_GROUP_OPRKND = 9  AND
                                          O2.WORKING_DATE = W2.WORKING_DATE AND
                                          W2.WORK_DATE < DATE_
                                );

           SELECT R.NAME
             INTO RESULT
             FROM P_G_LT_REASON_PAY LT,
                  P_G_REASON_PAY R,
                  P_CLAIM_PAY_OUT C
            WHERE C.P_CLAIM_PAY_OUT = P_CLAIM_PAY_OUT_ AND
                  LT.P_G_PAY_OUT_SUB_TYPE = C.P_G_PAY_OUT_SUB_TYPE AND
                  LT.P_G_REASON_PAY = R.P_G_REASON_PAY;
       END IF;

    RETURN RESULT;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;


  FUNCTION GET_THIRD_PAY_SUMM
  (
    G_PERSON_ IN NUMBER
  )
  RETURN NUMBER
  -- Тима(12.08.2011): функция возвращает сумму третей выплаты произведеной по вкладчику
  IS
    RESULT NUMBER;
    DATE_  DATE;
  BEGIN

       DATE_ := GET_THIRD_PAY_DATE(G_PERSON_);

       IF DATE_ IS NOT NULL THEN
           -- ДОСТАЕМ САМОЕ РАННЕЕ ЗАЯВЛЕНИЕ С КОТОРОГО ПРОИЗВОДИЛАСЬ ВЫПЛАТА
           SELECT SUM(O.SUMMA)
             INTO RESULT
             FROM P_CLAIM_PAY_OUT C,
                  P_CONTRACT P,
                  P_OPR O,
                  P_G_OPRKND K,
                  WORKING_DATE W
            WHERE C.P_CONTRACT = P.P_CONTRACT AND
                  P.G_PERSON_RECIPIENT = G_PERSON_ AND
                  P.P_G_CONTRACT_KND IN (1,10) AND
                  O.P_CONTRACT = P.P_CONTRACT AND
                  O.P_G_OPRKND = K.P_G_OPRKND  AND
                  K.P_G_GROUP_OPRKND = 9  AND
                  O.WORKING_DATE = W.WORKING_DATE AND
                  W.WORK_DATE = (  SELECT MAX(W2.WORK_DATE)
                                     FROM P_CLAIM_PAY_OUT C2,
                                          P_CONTRACT P2,
                                          P_OPR O2,
                                          P_G_OPRKND K2,
                                          WORKING_DATE W2
                                    WHERE C2.P_CONTRACT = P2.P_CONTRACT AND
                                          P2.G_PERSON_RECIPIENT = G_PERSON_ AND
                                          P2.P_G_CONTRACT_KND IN (1,10) AND
                                          O2.P_CONTRACT = P2.P_CONTRACT AND
                                          O2.P_G_OPRKND = K2.P_G_OPRKND  AND
                                          K2.P_G_GROUP_OPRKND = 9  AND
                                          O2.WORKING_DATE = W2.WORKING_DATE AND
                                          W2.WORK_DATE < DATE_
                                );
       END IF;

    RETURN RESULT;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;




  FUNCTION GET_LAST_TRANSFER_DATE
  (
    G_PERSON_ IN NUMBER
  )
  RETURN DATE
  -- Тима(22,07,2011): функция возвращает дату последнего перевода в другой фонд до 01.06.2006г. по вкладчику
  IS
    RESULT DATE;
  BEGIN

       SELECT MAX(W.WORK_DATE)
         INTO RESULT
         FROM P_CONTRACT P,
              P_OPR O,
              P_G_OPRKND K,
              WORKING_DATE W
        WHERE P.G_PERSON_RECIPIENT = G_PERSON_ AND
              P.P_G_CONTRACT_KND IN (1,10) AND
              O.P_CONTRACT = P.P_CONTRACT AND
              O.P_G_OPRKND = K.P_G_OPRKND  AND
              K.P_G_GROUP_OPRKND = 8  AND
              O.WORKING_DATE = W.WORKING_DATE AND
              W.WORK_DATE <= TO_DATE('01.06.2006','DD.MM.YYYY');

    RETURN RESULT;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION GET_LAST_TRANSFER_FUND
  (
    G_PERSON_ IN NUMBER
  )
  RETURN VARCHAR2
  -- Тима(22,07,2011): функция возвращает код фонда в который последний раз переводились накопления до 01.06.2006г. по вкладчику
  IS
    RESULT VARCHAR2(2);
  BEGIN

       SELECT N.PENS_FOND_CODE
         INTO RESULT
         FROM P_CLAIM_TRANSFER C,
              P_CONTRACT P,
              P_OPR O,
              P_G_OPRKND K,
              WORKING_DATE W,
              G_JUR_PERSON N
        WHERE C.P_CONTRACT = P.P_CONTRACT AND
              P.G_PERSON_RECIPIENT = G_PERSON_ AND
              P.P_G_CONTRACT_KND IN (1,10) AND
              O.P_CONTRACT = P.P_CONTRACT AND
              O.P_G_OPRKND = K.P_G_OPRKND  AND
              K.P_G_GROUP_OPRKND = 8  AND
              O.WORKING_DATE = W.WORKING_DATE AND
              W.WORK_DATE =  (
                               SELECT MAX(W.WORK_DATE)
                                 FROM P_CONTRACT P2,
                                      P_OPR O2,
                                      P_G_OPRKND K2,
                                      WORKING_DATE W2
                                WHERE P2.G_PERSON_RECIPIENT = G_PERSON_ AND
                                      P2.P_G_CONTRACT_KND IN (1,10) AND
                                      O2.P_CONTRACT = P2.P_CONTRACT AND
                                      O2.P_G_OPRKND = K2.P_G_OPRKND  AND
                                      K2.P_G_GROUP_OPRKND = 8  AND
                                      O2.WORKING_DATE = W2.WORKING_DATE AND
                                      W2.WORK_DATE <= TO_DATE('01.06.2006','DD.MM.YYYY')
                               ) AND
              N.G_PERSON = C.G_PERSON;

    RETURN RESULT;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;


  FUNCTION GET_LAST_TRANSFER_SUMM
  (
    G_PERSON_ IN NUMBER
  )
  RETURN NUMBER
  -- Тима(22,07,2011): функция возвращает сумму, которая последний раз переводилась в др. фонд до 01.06.2006г. по вкладчику
  IS
    RESULT NUMBER;
  BEGIN

       SELECT O.SUMMA
         INTO RESULT
         FROM P_CLAIM_TRANSFER C,
              P_CONTRACT P,
              P_OPR O,
              P_G_OPRKND K,
              WORKING_DATE W
        WHERE C.P_CONTRACT = P.P_CONTRACT AND
              P.G_PERSON_RECIPIENT = G_PERSON_ AND
              P.P_G_CONTRACT_KND IN (1,10) AND
              O.P_CONTRACT = P.P_CONTRACT AND
              O.P_G_OPRKND = K.P_G_OPRKND  AND
              K.P_G_GROUP_OPRKND = 8  AND
              O.WORKING_DATE = W.WORKING_DATE AND
              W.WORK_DATE =  (
                               SELECT MAX(W.WORK_DATE)
                                 FROM P_CONTRACT P2,
                                      P_OPR O2,
                                      P_G_OPRKND K2,
                                      WORKING_DATE W2
                                WHERE P2.G_PERSON_RECIPIENT = G_PERSON_ AND
                                      P2.P_G_CONTRACT_KND IN (1,10) AND
                                      O2.P_CONTRACT = P2.P_CONTRACT AND
                                      O2.P_G_OPRKND = K2.P_G_OPRKND  AND
                                      K2.P_G_GROUP_OPRKND = 8  AND
                                      O2.WORKING_DATE = W2.WORKING_DATE AND
                                      W2.WORK_DATE <= TO_DATE('01.06.2006','DD.MM.YYYY')
                               );

    RETURN RESULT;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION GET_G_PERSON_BY_P_OPR_IN
  (
    P_OPR_  IN NUMBER
  )
  RETURN VARCHAR2
  -- Тима(13.08.2011): функция возвращает НПФ из которого поступили деньги
  IS
    RESULT VARCHAR2(250);
  BEGIN

     RESULT := '';

     SELECT J.NAME
       INTO RESULT
       FROM P_LT_I_OPR_MT102 M,
            I_MT102 I,
            G_JUR_PERSON J
      WHERE M.P_OPR = P_OPR_ AND
            I.I_MT102 = M.I_MT102 AND
            J.PENS_FOND_CODE = I.ASSIGN
            AND J.CLOSE_DATE IS NULL
            AND ROWNUM = 1
            ;

    RETURN RESULT;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN '';
  END;

  FUNCTION GET_P_CONTRACT_AUTOTRANSFER
  (
    P_CONTRACT_  IN NUMBER
  )
  RETURN VARCHAR2
  -- Тима(13.08.2011): функция возвращает операцию автоперевода произведеную по договору вкладчика
  IS
    RESULT VARCHAR2(2000);
  BEGIN

     RESULT := '';

     FOR REC IN (
     -- ДОСТАЕМ ВСЕ ОПЕРАЦИИ АВТОПЕРЕВОДОВ ПО ВКЛАДЧИКУ
     SELECT 'Поступил перевод от ' || to_char(w.work_date,'dd.mm.yyyy') || ' из ' || GET_G_PERSON_BY_P_OPR_IN(O.P_OPR) STR
       --INTO RESULT
       FROM P_OPR O,
            P_G_OPRKND K,
            WORKING_DATE W
      WHERE O.P_CONTRACT = P_CONTRACT_   AND
            O.P_G_OPRKND = K.P_G_OPRKND  AND
            K.P_G_GROUP_OPRKND = 33  AND
            O.WORKING_DATE = W.WORKING_DATE/* AND
            W.WORK_DATE = (  SELECT MIN(W2.WORK_DATE)
                               FROM P_OPR O2,
                                    P_G_OPRKND K2,
                                    WORKING_DATE W2
                              WHERE O2.P_CONTRACT = P_CONTRACT_ AND
                                    O2.P_G_OPRKND = K2.P_G_OPRKND  AND
                                    K2.P_G_GROUP_OPRKND = 33  AND
                                    O2.WORKING_DATE = W2.WORKING_DATE
                          )*/
            --AND ROWNUM = 1
       )
       LOOP
         IF RESULT IS NULL THEN
           RESULT := REC.STR;
         ELSE
           RESULT := RESULT || ', '  || REC.STR;
         END IF;
       END LOOP;

    RETURN NVL(RESULT,'Перевод не поступал');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN 'Перевод не поступал';
    WHEN OTHERS THEN
       RETURN 'Ошибка при определениее входящих Переводов';
  END;

  FUNCTION GET_RECIPIENT_IS_DEPOSITOR
  (
    G_PERSON_ IN NUMBER,
    DATE_     IN DATE
  )
  RETURN NUMBER
  -- Тима(26,07,2011): функция возвращает 1-если человек на дату являлся вкладчиком, 0-если на тот момент не являлся
  IS
    RESULT NUMBER;
  BEGIN

    SELECT COUNT(*)
      INTO RESULT
      FROM P_CONTRACT P
     WHERE P.G_PERSON_RECIPIENT = G_PERSON_ AND
           P.CONTRACT_DATE >= DATE_ AND
           ( (P.DATE_CLOSE IS NULL) OR
             (P.DATE_CLOSE IS NOT NULL AND
              P.DATE_CLOSE <= DATE_)
           )
    ;

    IF RESULT > 0 THEN
      RESULT := 1;
    END IF;

    RETURN RESULT;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;


  FUNCTION P_GET_G_ACCOUNT_IPC
  --------------------------------------------------------
  -- ВОЗВРАЩАЕТ ID  СЧЕТА ИМЕННО ИПС С УЧЕТОМ МУЛЬТИПОРФЕЛЯ --
  -- ПЕРЕДАВАЕМЫЕ ПАРАМЕТРЫ:                            --
  -- 1. P_CONTRACT_   - ID ПЕНСИОННОГО ДОГОВОРА         --
  -- 2. PORTFOLIO_   - ID ПОРТФЕЛЯ         --
  -- Серик (весна 2011) --
  --------------------------------------------------------
    (
    P_CONTRACT_  IN P_CONTRACT.P_CONTRACT%TYPE,
    PORTFOLIO_   IN P_G_PORTFOLIO.P_G_PORTFOLIO%TYPE
    )
  RETURN G_ACCOUNT.G_ACCOUNT%TYPE IS
    RESULT G_ACCOUNT.G_ACCOUNT%TYPE;
  BEGIN

    BEGIN
      SELECT PA.G_ACCOUNT
        INTO RESULT
        FROM P_ACC PA,
             P_G_ACCKND PK
       WHERE PA.P_CONTRACT = P_CONTRACT_
         AND PA.P_G_ACCKND = PK.P_G_ACCKND
         AND PK.P_G_PORTFOLIO = PORTFOLIO_
         AND PK.P_G_GROUP_ACCKND in (1, 11, 16, 17, 21, 25);
    EXCEPTION
      WHEN TOO_MANY_ROWS THEN
        SELECT PA.G_ACCOUNT
          INTO RESULT
          FROM P_ACC PA,
               P_G_ACCKND PK
         WHERE PA.P_CONTRACT = P_CONTRACT_
           AND PA.P_G_ACCKND = PK.P_G_ACCKND
           AND PK.P_G_PORTFOLIO = PORTFOLIO_
           AND PK.P_G_CONTRACT_KND = P_GET_CONTRACT_KND(P_CONTRACT_)
           AND PK.P_G_GROUP_ACCKND = 1;
      WHEN NO_DATA_FOUND THEN
        RESULT := NULL;
      WHEN OTHERS THEN
        RAISE TYPES.E_FORCE_EXIT;
    END;
    RETURN RESULT;
  EXCEPTION
    WHEN TYPES.E_FORCE_EXIT THEN
      RETURN RESULT;
    WHEN OTHERS THEN
      RETURN RESULT;
  END;

   /*ГЕНЕРАЦИЯ НОМЕРА ПД*/
  /* Серик (весна 2011) */
  FUNCTION P_GENERATE_CONTRACT_NUM
   (CONTRACT_KND_      IN P_CONTRACT.P_G_CONTRACT_KND%TYPE,
    G_FILIAL_PARENT_   IN P_CONTRACT.G_FILIAL_PARENT%TYPE
   )RETURN VARCHAR2
  IS
   RESULT P_CONTRACT.NUM%TYPE;
   MAX_NUM_          P_LINK_FILIAL_NUMDOC.NUM%TYPE;
   CODE_FILIAL_      G_FILIAL.CODE%TYPE;
   CONTRACT_NUM_     P_G_CONTRACT_KND.CODE_FOR_CONTR_NUM%TYPE;
   P_G_CONTRACT_KND_ P_G_CONTRACT_KND.P_G_CONTRACT_TYPE%TYPE;
  BEGIN

   IF CONTRACT_KND_  = 12 THEN
     P_G_CONTRACT_KND_ := 11;
   ELSE
     P_G_CONTRACT_KND_ := CONTRACT_KND_;
   END IF;

    SELECT CODE
      INTO CODE_FILIAL_
      FROM G_FILIAL
     WHERE G_FILIAL = G_FILIAL_PARENT_;

    SELECT CODE_FOR_CONTR_NUM
      INTO CONTRACT_NUM_
      FROM P_G_CONTRACT_KND
     WHERE P_G_CONTRACT_TYPE = P_G_CONTRACT_KND_;

    BEGIN
    SELECT NUM + 1
      INTO MAX_NUM_
      FROM P_LINK_FILIAL_NUMDOC
     WHERE G_FILIAL = G_FILIAL_PARENT_
       AND P_G_CONTRACT_KND = P_G_CONTRACT_KND_
       AND TYPE_OBJ = 2;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        MAX_NUM_ := 1;
        INSERT INTO P_LINK_FILIAL_NUMDOC (G_FILIAL,NUM,TYPE_OBJ,P_G_CONTRACT_KND)
               VALUES(G_FILIAL_PARENT_, MAX_NUM_, 2, P_G_CONTRACT_KND_);
    END;

     RESULT := UPPER(CONTRACT_NUM_) || '-' || UPPER(CODE_FILIAL_) || '-' || LPAD(TO_CHAR(MAX_NUM_), 8, '0');

    RETURN RESULT;
  END;

   /*ГЕНЕРАЦИЯ НОМЕРА СЧЕТА*/
  /* Серик (весна 2011) */
  FUNCTION P_GENERATE_CODE_ACC
    (
    P_CONTRACT_        IN P_CONTRACT.P_CONTRACT%TYPE,
    P_G_PORTFOLIO_     IN P_G_PORTFOLIO.P_G_PORTFOLIO%TYPE,
    P_G_ACCKND_        IN P_G_ACCKND.P_G_ACCKND%TYPE
    )RETURN VARCHAR2
  IS
   RESULT VARCHAR2(50);
   CODE_FILIAL_      G_FILIAL.CODE%TYPE;
   CODE_IPS_         G_FILIAL.CODE_IPS%TYPE;
   CODE_FOND_        VARCHAR2(2);
   L_PLAN_ACCCODE_   VARCHAR2(6);
   P_G_CONTRACT_KND_ P_CONTRACT.P_G_CONTRACT_KND%TYPE;
   G_FILIAL_PARENT_  P_CONTRACT.G_FILIAL_PARENT%TYPE;
   NUM_CONTRACT_     P_CONTRACT.NUM%TYPE;
   IS_IPS_           P_G_ACCKND.P_G_GROUP_ACCKND%TYPE;
   Err_Code          Types.TErr_Code;
   Err_Msg           Types.TErr_Msg;
  BEGIN

    if Connection_Param.idUser Is Null then
      Connection_Param.Set_Params(Err_Code => Err_Code,
                                  Err_Msg  => Err_Msg);
      if Err_Code <> 0 then
        Err_Msg  := Err_Msg;
        raise Types.E_Force_Exit;
      end if;
    end if;

    -- НОМЕР БАЛАНСОВОГО СЧЕТА А ИМЕННО "339065" --
    L_PLAN_ACCCODE_ := '339065';

    -- СЧИТАЕМ ДАННЫЕ ПО КОНТРАКТУ ---
    SELECT DECODE(P.P_G_CONTRACT_KND, 10, 1, 11, 2, 12, 2, 4),
           P.NUM,
           P.G_FILIAL_PARENT
      INTO P_G_CONTRACT_KND_,
           NUM_CONTRACT_,
           G_FILIAL_PARENT_
      FROM P_CONTRACT P
     WHERE P.P_CONTRACT = P_CONTRACT_;

    SELECT P_G_GROUP_ACCKND
      INTO IS_IPS_
      FROM P_G_ACCKND
     WHERE P_G_ACCKND = P_G_ACCKND_;

    -- КОД ФИЛИАЛА --
    /*SELECT CODE
      INTO CODE_FILIAL_
      FROM G_FILIAL
     WHERE G_FILIAL = G_FILIAL_PARENT_;*/

     CODE_FILIAL_ := CONNECTION_PARAM.CFILIAL;
     CODE_IPS_    := CONNECTION_PARAM.CODE_IPS;

    -- КОД ФОНДА --
    CODE_FOND_ := '00';--PARAMS.GET_SYSTEM_SETUP_PARAM('FOND_CODE');

    IF IS_IPS_ = 1 THEN
    	RESULT := P_G_CONTRACT_KND_ || L_PLAN_ACCCODE_ || CODE_IPS_ || CODE_FOND_ || CODE_FILIAL_ || SUBSTR(NUM_CONTRACT_, INSTR(NUM_CONTRACT_, '-', 1, 2)+1, 8) || NVL(TO_CHAR(P_G_PORTFOLIO_), '');
    ELSE
     RESULT := P_G_CONTRACT_KND_ || L_PLAN_ACCCODE_ || CODE_IPS_ || CODE_FOND_ || CODE_FILIAL_ || SUBSTR(NUM_CONTRACT_, INSTR(NUM_CONTRACT_, '-', 1, 2)+1, 8) || NVL(TO_CHAR(P_G_PORTFOLIO_), '');
    END IF;

    RETURN RESULT;
  END;

  FUNCTION P_GET_IS_ACTIV_CONTRACT
  --------------------------------------------------------
  -- Возвращает 0 или 1, признак активности договора по данному получателю--
  -- Если хоть один из договоров закрытый то 1 иначе 0  --
  -- Передаваемые параметры:                            --
  -- 1. G_Person_Recipient_   - Id получателя           --
  -- Серик (весна 2011) --
  --------------------------------------------------------
  (
  G_PERSON_RECIPIENT_  IN P_CONTRACT.G_PERSON_RECIPIENT%type
  )
  RETURN NUMBER IS
  RESULT       NUMBER;
  Cnt_         NUMBER;
  CntContract_ NUMBER;
  BEGIN

  begin
    select Count(1)
      into Cnt_
      from P_CONTRACT
     where G_PERSON_RECIPIENT = G_PERSON_RECIPIENT_
       and DATE_CLOSE is not null;
  exception
    when OTHERS then
      raise Types.E_Force_Exit;
  end;

  begin
    select Count(1)
      into CntContract_
      from P_CONTRACT
     where G_PERSON_RECIPIENT = G_PERSON_RECIPIENT_;
  exception
    when OTHERS then
      raise Types.E_Force_Exit;
  end;

  if Cnt_ = CntContract_ then
  	RESULT := 1;
  else
    RESULT := 0;
  end if;

  RETURN RESULT;
  EXCEPTION
    WHEN Types.E_Force_Exit THEN
      RETURN RESULT;
    WHEN OTHERS THEN
      RETURN RESULT;
  END;

  FUNCTION P_GET_CONTRACT_G_PERSON
  -------------------------------------------------------------
  -- Возвращает G_Person (получатель) по конкретному контракту
  -- Передаваемые параметры:
  -- 1. P_Contract_   - Id пенсионного договора
  -- Серик (май 2011)
  -------------------------------------------------------------
  (
  P_Contract_  in P_CONTRACT.P_CONTRACT%type
  )
  RETURN P_CONTRACT.G_PERSON_RECIPIENT%type is
    Result P_CONTRACT.G_PERSON_RECIPIENT%type;
  BEGIN

    select p.G_PERSON_RECIPIENT
      into Result
      from P_CONTRACT p
     where p.P_CONTRACT = P_Contract_;

    RETURN Result;
  EXCEPTION
    WHEN others THEN
      RETURN null;
  END;

  -------------------------------------------------------------
  /* Темеков А.А.
     Функция возвращает ФИО вкладчика по контракту
  */
  -------------------------------------------------------------
  FUNCTION P_GET_FIO_BY_CONTRACT(
    P_CONTRACT_ IN NUMBER
  )
  RETURN VARCHAR2
  IS
    RESULT varchar2(500) := null;
  BEGIN

    select gnp.fm||' '||gnp.nm||' '||gnp.ft
      into RESULT
      from g_nat_person gnp,
           p_contract pc
     where gnp.g_person = pc.g_person_recipient
       and pc.p_contract = P_CONTRACT_;

    RETURN(RESULT);
  END P_GET_FIO_BY_CONTRACT;

  FUNCTION P_GET_G_PERSON_SIC
  -------------------------------------------------------------
  -- Возвращает СИК по конкретному G_Person (вкладчика)
  -- Передаваемые параметры:
  -- 1. G_PERSON_   - Id вкладчика
  -- Серик (май 2011)
  -------------------------------------------------------------
  (
  G_PERSON_  in G_NAT_PERSON.G_PERSON%type
  )
  RETURN G_NAT_PERSON.OPV%type is
    Result G_NAT_PERSON.OPV%type;
  BEGIN

    select n.OPV
      into Result
      from G_NAT_PERSON n
     where n.G_PERSON = G_PERSON_;

    RETURN Result;
  EXCEPTION
    WHEN others THEN
      RETURN null;
  END;

  -------------------------------------------------------------
  -- Возвращает актуальный(последний) контракт по G_Person
  -- Темеков А.А. 06.02.2012
  -- приоритет ОПВ, если закрыт, проверяю на открытый ТД,
  -- если и он закрыт, то далее ДПВ, ДППВ,
  -- если все закрыты, то опять же беру последний ОПВ -> ТД -> ДППВ -> ДПВ
  -------------------------------------------------------------
  FUNCTION P_GET_CONTRACT_BY_G_PERSON(
    G_PERSON_ in P_CONTRACT.P_CONTRACT%type
  )
  RETURN P_CONTRACT.P_CONTRACT%type
  is
    Result P_CONTRACT.P_CONTRACT%type := null;
  BEGIN
    FOR REC IN (-- среди открытых
                select 1 rsort,
                       pc.contract_date,
                       pc.p_contract
                  from p_contract pc
                 where pc.g_person_recipient = G_PERSON_
                   and pc.p_g_contract_knd = 10
                   and pc.date_close is null
                union
                select 2 rsort,
                       pc.contract_date,
                       pc.p_contract
                  from p_contract pc
                 where pc.g_person_recipient = G_PERSON_
                   and pc.p_g_contract_knd = 1
                   and pc.date_close is null
                union
                select 3 rsort,
                       pc.contract_date,
                       pc.p_contract
                  from p_contract pc
                 where pc.g_person_recipient = G_PERSON_
                   and pc.p_g_contract_knd = 11
                   and pc.date_close is null
                union
                select 4 rsort,
                       pc.contract_date,
                       pc.p_contract
                  from p_contract pc
                 where pc.g_person_recipient = G_PERSON_
                   and pc.p_g_contract_knd = 12
                   and pc.date_close is null
                union
                -- среди всех
                select 5 rsort,
                       pc.contract_date,
                       pc.p_contract
                  from p_contract pc
                 where pc.g_person_recipient = G_PERSON_
                   and pc.p_g_contract_knd = 10
                union
                select 6 rsort,
                       pc.contract_date,
                       pc.p_contract
                  from p_contract pc
                 where pc.g_person_recipient = G_PERSON_
                   and pc.p_g_contract_knd = 1
                union
                select 7 rsort,
                       pc.contract_date,
                       pc.p_contract
                  from p_contract pc
                 where pc.g_person_recipient = G_PERSON_
                   and pc.p_g_contract_knd = 11
                union
                select 8 rsort,
                       pc.contract_date,
                       pc.p_contract
                  from p_contract pc
                 where pc.g_person_recipient = G_PERSON_
                   and pc.p_g_contract_knd = 12
                order by 1, 2 desc, 3 )
    LOOP
      Result := Rec.p_contract;
      Return Result;
    END LOOP;

    return Result;

  EXCEPTION
    WHEN others THEN
      RETURN -1;
  END P_GET_CONTRACT_BY_G_PERSON;

  -------------------------------------------------------------
  -- Возвращает актуальный(последний) контракт по G_Person
  -- Темеков А.А. 18.05.2012
  -- приоритет ОПВ, если закрыт, проверяю на открытый ТД,
  -- если все закрыты, то опять же беру последний ОПВ -> ТД
  -------------------------------------------------------------
  FUNCTION P_GET_CONTRACT_BY_G_PERSON_TD(
    G_PERSON_ in P_CONTRACT.P_CONTRACT%type
  )
  RETURN P_CONTRACT.P_CONTRACT%type
  is
    Result P_CONTRACT.P_CONTRACT%type := null;
  BEGIN
    FOR REC IN (-- среди открытых
                select 1 rsort,
                       pc.contract_date,
                       pc.p_contract
                  from p_contract pc
                 where pc.g_person_recipient = G_PERSON_
                   and pc.p_g_contract_knd = 10
                   and pc.date_close is null
                union
                select 2 rsort,
                       pc.contract_date,
                       pc.p_contract
                  from p_contract pc
                 where pc.g_person_recipient = G_PERSON_
                   and pc.p_g_contract_knd = 1
                   and pc.date_close is null
                union
                -- среди всех
                select 5 rsort,
                       pc.contract_date,
                       pc.p_contract
                  from p_contract pc
                 where pc.g_person_recipient = G_PERSON_
                   and pc.p_g_contract_knd = 10
                union
                select 6 rsort,
                       pc.contract_date,
                       pc.p_contract
                  from p_contract pc
                 where pc.g_person_recipient = G_PERSON_
                   and pc.p_g_contract_knd = 1
                order by 1, 2 desc, 3)
    LOOP
      Result := Rec.p_contract;
      Return Result;
    END LOOP;

    return Result;

  EXCEPTION
    WHEN others THEN
      RETURN -1;
  END P_GET_CONTRACT_BY_G_PERSON_TD;

  FUNCTION P_GET_CONTRACT_KND
  -------------------------------------------------------------
  -- Возвращает Вид договора по конкретному контракту
  -- Передаваемые параметры:
  -- 1. P_Contract_   - Id пенсионного договора
  -- Серик (май 2011)
  -------------------------------------------------------------
  (
  P_Contract_  in P_CONTRACT.P_CONTRACT%type
  )
  RETURN P_CONTRACT.P_G_CONTRACT_KND%type is
    Result P_CONTRACT.P_G_CONTRACT_KND%type;
  BEGIN

    select p.P_G_CONTRACT_KND
      into Result
      from P_CONTRACT p
     where p.P_CONTRACT = P_Contract_;

    RETURN Result;
  EXCEPTION
    WHEN others THEN
      RETURN null;
  END;

  /*ВОЗВРАЩАЕТ ПОРТФЕЛЬ Т.Е. НА КАКОМ ПОРТФЕЛЕ НАХОДИТСЯ КОНКРЕТНЫЙ КОНТРАКТ*/
  FUNCTION P_GET_CONTRACT_PORTFOLIO
    (P_CONTRACT_  IN P_CONTRACT.P_CONTRACT%TYPE)
     RETURN P_G_PORTFOLIO.P_G_PORTFOLIO%TYPE IS
     RESULT P_G_PORTFOLIO.P_G_PORTFOLIO%TYPE;
  BEGIN
    BEGIN
      SELECT P.P_G_PORTFOLIO
        INTO RESULT
        FROM P_CONTRACT_PORTFOLIO P
       WHERE P.P_CONTRACT = P_CONTRACT_
         AND P.PERCENTAGE = 100;
    EXCEPTION
      WHEN OTHERS THEN
        RESULT := 1;
    END;

    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 1;
  END;

  /*ВОЗВРАЩАЕТ ВИД ЮРИДИЧЕСКОГО ЛИЦА ПО КОНКРЕТНОМУ G_PERSON*/
  FUNCTION P_GET_G_PERSON_KND
  (
  G_PERSON_  in G_PERSON.G_PERSON%type
  )
  RETURN G_PERSON.G_PERSON_KIND%type is
    Result G_PERSON.G_PERSON_KIND%type;
  BEGIN

    select g.G_PERSON_KIND
      into Result
      from G_PERSON g
     where g.G_PERSON = G_PERSON_;

    RETURN Result;
  EXCEPTION
    WHEN others THEN
      RETURN null;
  END;

-- ====================================================================================================================
--                                         INSERT
-- ====================================================================================================================
   /* Вставка записи в таблицу P_Account_State */
  /* Серик (весна 2011) */
  PROCEDURE INSERT_P_ACCOUNT_STATE(
    G_ACCOUNT_       IN   G_ACCOUNT.G_ACCOUNT%TYPE,
    WORKING_DATE_    IN   WORKING_DATE.WORKING_DATE%TYPE,
    WORK_DATE_       IN   WORKING_DATE.WORK_DATE%TYPE,
    ERR_CODE         OUT	TYPES.TERR_CODE,
    ERR_MSG	         OUT	TYPES.TERR_MSG)
  IS
    PROCNAME               CONSTANT  TYPES.TPROC_NAME := 'PENSION_PACK.INSERT_P_ACCOUNT_STATE';
    PNT_                   VARCHAR2(20);
    IS_PREV_STATE_EXISTS_  PLS_INTEGER;
    IS_CUR_STATE_EXISTS_   PLS_INTEGER;
    PREVASREC              MAIN.P_ACCOUNT_STATE%ROWTYPE;
  BEGIN
    ERR_CODE	:= 0;
    ERR_MSG   := ' ';

    DECLARE
    	TMP_	         MAIN.P_ACCOUNT_STATE.P_ACCOUNT_STATE%TYPE;
    BEGIN
  	 	SELECT PAS.P_ACCOUNT_STATE
  		  INTO TMP_
  		  FROM P_ACCOUNT_STATE PAS
  		 WHERE PAS.G_ACCOUNT = G_ACCOUNT_
         AND PAS.WORKING_DATE = WORKING_DATE_;

      IS_CUR_STATE_EXISTS_ := 1;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IS_CUR_STATE_EXISTS_ := 0;
    END;

    IF IS_CUR_STATE_EXISTS_ = 0 THEN
      PNT_ := '01';
      BEGIN
        SELECT PAS.*
          INTO PREVASREC
          FROM P_ACCOUNT_STATE PAS
         WHERE PAS.G_ACCOUNT = G_ACCOUNT_
           AND PAS.WORKING_DATE =(SELECT MAX(K1.WORKING_DATE)
                                    FROM P_ACCOUNT_STATE K1
                                   WHERE K1.G_ACCOUNT = G_ACCOUNT_
                                     AND K1.WORKING_DATE < WORKING_DATE_
                                     AND TO_CHAR(WORKING_DATE_PACK.GET_WORK_DATE_BY_WORKING_DATE(K1.WORKING_DATE), 'YYYY') = TO_CHAR(WORK_DATE_, 'YYYY')
                                 );

        IS_PREV_STATE_EXISTS_ := 1;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            PREVASREC := NULL;
            IS_PREV_STATE_EXISTS_ := 0;
      END;

      IF IS_PREV_STATE_EXISTS_ = 1 THEN
        INSERT INTO P_ACCOUNT_STATE
                    (P_ACCOUNT_STATE,
                     G_ACCOUNT,
                     WORKING_DATE,
                     INPUT,
                     TURN_DEBET,
                     TURN_CREDIT,
                     OUTPUT,
                     INPUT_CU,
                     TURN_DEBET_CU,
                     TURN_CREDIT_CU,
                     OUTPUT_CU,
                     IS_LAST)
                  VALUES
                    (SEQ_P_ACCOUNT_STATE.NEXTVAL,
                     G_ACCOUNT_,
                     WORKING_DATE_,
                     PREVASREC.OUTPUT,
                     0,
                     0,
                     PREVASREC.OUTPUT,
                     PREVASREC.OUTPUT_CU,
                     0,
                     0,
                     PREVASREC.OUTPUT_CU,
                     1);
      ELSIF IS_PREV_STATE_EXISTS_ = 0 THEN
        INSERT INTO P_ACCOUNT_STATE
                    (P_ACCOUNT_STATE,
                     G_ACCOUNT,
                     WORKING_DATE,
                     INPUT,
                     TURN_DEBET,
                     TURN_CREDIT,
                     OUTPUT,
                     INPUT_CU,
                     TURN_DEBET_CU,
                     TURN_CREDIT_CU,
                     OUTPUT_CU,
                     IS_LAST)
                  VALUES
                    (SEQ_P_ACCOUNT_STATE.NEXTVAL,
                     G_ACCOUNT_,
                     WORKING_DATE_,
                     0,--PREVASREC.OUTPUT,
                     0,
                     0,
                     0,
                     0,
                     0,
                     0,
                     0,
                     1);
      END IF;-- IF IS_STATE_EXISTS_ = 0
    END IF;-- IF IS_CUR_STATE_EXISTS_ = 0

    EXCEPTION
      WHEN OTHERS THEN
  			ERR_CODE := SQLCODE;
  			ERR_MSG  := PROCNAME || ' ' || PNT_ || ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, SQLERRM);
  END;


-- ====================================================================================================================
-- ===============================    UPDATE   ========================================================================
-- ====================================================================================================================



-- ====================================================================================================================
-- ===============================    DELETE   ========================================================================
-- ====================================================================================================================

    PROCEDURE PRC04(
        P_                                 IN P_G_FILE_GCVP_FORMAT.P_G_FILE_GCVP_FORMAT%TYPE,
        PARAM_                             IN NUMBER, -- не используется, зарезервировано
    	  ERR_CODE	                        OUT	TYPES.TERR_CODE,
      	ERR_MSG	                          OUT	TYPES.TERR_MSG
        )
    IS
       -- Процедура удаления записи
       PROCNAME                    CONSTANT  TYPES.TPROC_NAME :=  'PENSION_PACK.PRC04';
    BEGIN
        ERR_CODE := 0;
        ERR_MSG  := '';

        -- Check official rights
        begin
          HasRight := ADM.OFFICIAL_RIGHT_PACK.Is_Offic_Has_Pack_Proc_Right(
            'PENSION_PACK',
            'PRC04',
            Err_Code, Err_Msg);

          if HasRight = 0 then
            Err_Code := -20500;
            Err_Msg  := ProcName || ' 01' ||
              ADM.ERROR_PACK.Get_Err_Msg('0110', Err_Code, ' ');
                -- 'Недостаточно прав для выполнения операции';
              RAISE ADM.TYPES.E_ExecError;
          end if;
        end;

        COMMIT;

    EXCEPTION
      WHEN Adm.Types.E_ExecError THEN
        ROLLBACK;

      WHEN OTHERS THEN
    		ERR_CODE := SQLCODE;
    		ERR_MSG  := PROCNAME || ' 00' || ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, SQLERRM);
        ROLLBACK;
    END;

-- ====================================================================================================================
-- ===============================    CHECKS   ========================================================================
-- ====================================================================================================================
    -- Темеков А.А. 14,05,2011
    -- есть ли физ лицо с такими же ФИО, дата рождения и пол
    -- пол и ДР передается только при заведении нового вкладчика
    FUNCTION IS_SUCH_PERSON_EXIST(
        fm_                IN  g_nat_person.fm%type,
        nm_                IN  g_nat_person.nm%type,
        ft_                IN  g_nat_person.ft%type,
        dt_                IN  g_nat_person.dt%type,
        g_sex_             IN  g_nat_person.g_sex%type,
        ERR_CODE           OUT  TYPES.TERR_CODE,
        ERR_MSG            OUT  TYPES.TERR_MSG
        ) RETURN NUMBER
    IS
        RESULT   NUMBER := 0;  --  >0  - есть, 0 - нет
--        Cur   Types.TCur;
--        str_  varchar2(500);
    BEGIN
        ERR_CODE := 0;
--== Солдатов 20171226
        SELECT count(*)
          INTO Result
          FROM g_nat_person gn
         WHERE (gn.fm) = Upper(fm_)
           AND (gn.nm) = Upper(nm_)
           AND (gn.ft) = Upper(ft_)
           and gn.dt   = nvl(to_date(to_char(dt_,'dd.mm.yyyy'),'dd.mm.yyyy'),gn.dt)
           and gn.g_sex = nvl(to_char(g_sex_), gn.g_sex)
        ;
/*
        str_ := 'SELECT count(*)
                   FROM g_nat_person gn
                  WHERE upper(gn.fm) = upper('''||fm_||''')'||
                   ' AND upper(gn.ft) = upper('''||ft_||''')'||
                   ' AND upper(gn.nm) = upper('''||nm_||''')'||
                   ' AND gn.dt = nvl(to_date('''||to_char(dt_, 'dd.mm.yyyy')||''', ''dd.mm.yyyy''), gn.dt)'||
                   ' AND gn.g_sex = '||nvl(to_char(g_sex_), 'gn.g_sex');

        Open Cur for
          str_;

        Fetch Cur into Result;
*/
--==
        RETURN RESULT;
    EXCEPTION
      WHEN OTHERS THEN
        ERR_CODE := SQLCODE;
        ERR_MSG  := SQLERRM;
        return 0;
    END IS_SUCH_PERSON_EXIST;

    -- Темеков А.А. 22.06,2011
    -- открыт или закрыт контракт
    FUNCTION IS_CONTRACT_IS_OPEN(
      P_CONTRACT_        IN  P_CONTRACT.P_CONTRACT%type
      ) RETURN NUMBER
    IS
        RESULT   NUMBER := 0;  --  0  - ЗАКРЫТ, 1 - ОТКРЫТ
    BEGIN
        SELECT DECODE(P.DATE_CLOSE, NULL, 1, 0)
          into RESULT
          FROM P_CONTRACT P
         WHERE P.P_CONTRACT = P_CONTRACT_;

        RETURN RESULT;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN -1;
    END IS_CONTRACT_IS_OPEN;

    FUNCTION Get_Sum_OPV_By_Period(
      P_Contract_        IN  P_CONTRACT.P_CONTRACT%type default null,
      G_Filial_          In  G_FILIAL.G_FILIAL%type default null,
      Begin_Date_        in Date,
      End_Date_          in Date
      ) RETURN k_Types.TSumm_18_2
    IS
        RESULT   k_Types.TSumm_18_2;
        ---Функция фозвращает сумму обязательных взносов клиента
        -- за заданный перод в разрезе контрактов по филиално
    BEGIN
        if G_Filial_ is null then
            begin
                SELECT nvl(sum(nvl(o.SUMMA,0)),0)
                  into RESULT
                  FROM P_OPR o,
                       P_G_OPRKND ok,
                       WORKING_DATE wd
                 WHERE o.P_CONTRACT = P_Contract_
                   and o.P_G_OPRKND = ok.P_G_OPRKND
                   and ok.P_G_GROUP_OPRKND in (2,3)
                   and o.WORKING_DATE = wd.WORKING_DATE
                   and wd.WORK_DATE between Begin_Date_ and End_Date_;
            exception
              when NO_DATA_FOUND then
                 RESULT := 0;
            end;
        else
            begin
                SELECT nvl(sum(nvl(o.SUMMA,0)),0)
                  into RESULT
                  FROM P_OPR o,
                       P_G_OPRKND ok,
                       WORKING_DATE wd,
                       P_CONTRACT c
                 WHERE o.P_CONTRACT = c.P_CONTRACT
                   and c.G_FILIAL = G_Filial_
                   and o.P_G_OPRKND = ok.P_G_OPRKND
                   and ok.P_G_GROUP_OPRKND in (2,3)
                   and c.P_G_CONTRACT_STATUS = 5
                   and o.WORKING_DATE = wd.WORKING_DATE
                   and wd.WORK_DATE between Begin_Date_ and End_Date_;
            exception
              when NO_DATA_FOUND then
                 RESULT := 0;
            end;
        end if;

        RETURN RESULT;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;

    FUNCTION Get_Sum_TransferIn_By_Period(
      P_Contract_        IN  P_CONTRACT.P_CONTRACT%type default null,
      G_Filial_          In  G_FILIAL.G_FILIAL%type default null,
      Begin_Date_        in Date,
      End_Date_          in Date
      ) RETURN k_Types.TSumm_18_2
    IS
        RESULT   k_Types.TSumm_18_2;
        ---Функция фозвращает сумму входящих переводов
        -- за заданный перод в разрезе контрактов или по филиално
    BEGIN
        if G_Filial_ is null then
            begin
                SELECT nvl(sum(nvl(o.SUMMA,0)),0)
                  into RESULT
                  FROM P_OPR o,
                       P_G_OPRKND ok,
                       WORKING_DATE wd
                 WHERE o.P_CONTRACT = P_Contract_
                   and o.P_G_OPRKND = ok.P_G_OPRKND
                   and ok.P_G_GROUP_OPRKND in (32,33,55,113)
                   and o.WORKING_DATE = wd.WORKING_DATE
                   and wd.WORK_DATE between Begin_Date_ and End_Date_;
            exception
              when NO_DATA_FOUND then
                 RESULT := 0;
            end;
        else
            begin
                SELECT nvl(sum(nvl(o.SUMMA,0)),0)
                  into RESULT
                  FROM P_OPR o,
                       P_G_OPRKND ok,
                       WORKING_DATE wd,
                       P_CONTRACT c
                 WHERE o.P_CONTRACT = c.P_CONTRACT
                   and c.G_FILIAL = G_Filial_
                   and o.P_G_OPRKND = ok.P_G_OPRKND
                   and ok.P_G_GROUP_OPRKND in (32,33,55,113)
                   and c.P_G_CONTRACT_STATUS = 5
                   and o.WORKING_DATE = wd.WORKING_DATE
                   and wd.WORK_DATE between Begin_Date_ and End_Date_;
            exception
              when NO_DATA_FOUND then
                 RESULT := 0;
            end;
        end if;
        RETURN RESULT;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;

    FUNCTION Get_Sum_TransferOut_By_Period(
      P_Contract_        IN  P_CONTRACT.P_CONTRACT%type default null,
      G_Filial_          In  G_FILIAL.G_FILIAL%type default null,
      Begin_Date_        in Date,
      End_Date_          in Date
      ) RETURN k_Types.TSumm_18_2
    IS
        RESULT   k_Types.TSumm_18_2;
        ---Функция фозвращает сумму исходящих переводов
        -- за заданный перод в разрезе контрактов или по филиално
    BEGIN
        if G_Filial_ is null then
            begin
                SELECT nvl(sum(nvl(o.SUMMA,0)),0)
                  into RESULT
                  FROM P_OPR o,
                       P_G_OPRKND ok,
                       WORKING_DATE wd
                 WHERE o.P_CONTRACT = P_Contract_
                   and o.P_G_OPRKND = ok.P_G_OPRKND
                   and ok.P_G_GROUP_OPRKND in (8,102,122,123)
                   and o.WORKING_DATE = wd.WORKING_DATE
                   and wd.WORK_DATE between Begin_Date_ and End_Date_;
            exception
              when NO_DATA_FOUND then
                 RESULT := 0;
            end;
        else
            begin
                SELECT nvl(sum(nvl(o.SUMMA,0)),0)
                  into RESULT
                  FROM P_OPR o,
                       P_G_OPRKND ok,
                       WORKING_DATE wd,
                       P_CONTRACT c
                 WHERE o.P_CONTRACT = c.P_CONTRACT
                   and c.G_FILIAL = G_Filial_
                   and o.P_G_OPRKND = ok.P_G_OPRKND
                   and ok.P_G_GROUP_OPRKND in (8,102,122,123)
                   and c.P_G_CONTRACT_STATUS = 5
                   and o.WORKING_DATE = wd.WORKING_DATE
                   and wd.WORK_DATE between Begin_Date_ and End_Date_;
            exception
              when NO_DATA_FOUND then
                 RESULT := 0;
            end;
        end if;

        RETURN RESULT;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;

    FUNCTION Get_CNT_OPV_By_Period(
      P_Contract_        IN  P_CONTRACT.P_CONTRACT%type default null,
      G_Filial_          In  G_FILIAL.G_FILIAL%type default null,
      Begin_Date_        in Date,
      End_Date_          in Date
      ) RETURN k_Types.TSumm_18_2
    IS
        RESULT   k_Types.TSumm_18_2;
        ---Функция фозвращает количество обязательных взносов клиента
        -- за заданный перод в разрезе контрактов по филиално
    BEGIN
        if G_Filial_ is null then
            begin
                SELECT nvl(count(nvl(o.P_OPR,0)),0)
                  into RESULT
                  FROM P_OPR o,
                       P_G_OPRKND ok,
                       WORKING_DATE wd
                 WHERE o.P_CONTRACT = P_Contract_
                   and o.P_G_OPRKND = ok.P_G_OPRKND
                   and ok.P_G_GROUP_OPRKND in (2,3)
                   and o.WORKING_DATE = wd.WORKING_DATE
                   and wd.WORK_DATE between Begin_Date_ and End_Date_;
            exception
              when NO_DATA_FOUND then
                 RESULT := 0;
            end;
        else
            begin
                SELECT nvl(count(nvl(o.P_OPR,0)),0)
                  into RESULT
                  FROM P_OPR o,
                       P_G_OPRKND ok,
                       WORKING_DATE wd,
                       P_CONTRACT c
                 WHERE o.P_CONTRACT = c.P_CONTRACT
                   and c.G_FILIAL = G_Filial_
                   and o.P_G_OPRKND = ok.P_G_OPRKND
                   and ok.P_G_GROUP_OPRKND in (2,3)
                   and c.P_G_CONTRACT_STATUS = 5
                   and o.WORKING_DATE = wd.WORKING_DATE
                   and wd.WORK_DATE between Begin_Date_ and End_Date_;
            exception
              when NO_DATA_FOUND then
                 RESULT := 0;
            end;
        end if;

        RETURN RESULT;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;

    FUNCTION Get_CNT_TransferIn_By_Period(
      P_Contract_        IN  P_CONTRACT.P_CONTRACT%type default null,
      G_Filial_          In  G_FILIAL.G_FILIAL%type default null,
      Begin_Date_        in Date,
      End_Date_          in Date
      ) RETURN k_Types.TSumm_18_2
    IS
        RESULT   k_Types.TSumm_18_2;
        ---Функция фозвращает количество входящих переводов
        -- за заданный перод в разрезе контрактов или по филиално
    BEGIN
        if G_Filial_ is null then
            begin
                SELECT nvl(count(nvl(o.P_OPR,0)),0)
                  into RESULT
                  FROM P_OPR o,
                       P_G_OPRKND ok,
                       WORKING_DATE wd
                 WHERE o.P_CONTRACT = P_Contract_
                   and o.P_G_OPRKND = ok.P_G_OPRKND
                   and ok.P_G_GROUP_OPRKND in (32,33,55,113)
                   and o.WORKING_DATE = wd.WORKING_DATE
                   and wd.WORK_DATE between Begin_Date_ and End_Date_;
            exception
              when NO_DATA_FOUND then
                 RESULT := 0;
            end;
        else
            begin
                SELECT nvl(count(nvl(o.P_OPR,0)),0)
                  into RESULT
                  FROM P_OPR o,
                       P_G_OPRKND ok,
                       WORKING_DATE wd,
                       P_CONTRACT c
                 WHERE o.P_CONTRACT = c.P_CONTRACT
                   and c.G_FILIAL = G_Filial_
                   and o.P_G_OPRKND = ok.P_G_OPRKND
                   and ok.P_G_GROUP_OPRKND in (32,33,55,113)
                   and c.P_G_CONTRACT_STATUS = 5
                   and o.WORKING_DATE = wd.WORKING_DATE
                   and wd.WORK_DATE between Begin_Date_ and End_Date_;
            exception
              when NO_DATA_FOUND then
                 RESULT := 0;
            end;
        end if;
        RETURN RESULT;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;

    FUNCTION Get_CNT_TransferOut_By_Period(
      P_Contract_        IN  P_CONTRACT.P_CONTRACT%type default null,
      G_Filial_          In  G_FILIAL.G_FILIAL%type default null,
      Begin_Date_        in Date,
      End_Date_          in Date
      ) RETURN k_Types.TSumm_18_2
    IS
        RESULT   k_Types.TSumm_18_2;
        ---Функция фозвращает количество исходящих переводов
        -- за заданный перод в разрезе контрактов или по филиално
    BEGIN
        if G_Filial_ is null then
            begin
                SELECT nvl(count(nvl(o.P_OPR,0)),0)
                  into RESULT
                  FROM P_OPR o,
                       P_G_OPRKND ok,
                       WORKING_DATE wd
                 WHERE o.P_CONTRACT = P_Contract_
                   and o.P_G_OPRKND = ok.P_G_OPRKND
                   and ok.P_G_GROUP_OPRKND in (8,102,122,123)
                   and o.WORKING_DATE = wd.WORKING_DATE
                   and wd.WORK_DATE between Begin_Date_ and End_Date_;
            exception
              when NO_DATA_FOUND then
                 RESULT := 0;
            end;
        else
            begin
                SELECT nvl(count(nvl(o.P_OPR,0)),0)
                  into RESULT
                  FROM P_OPR o,
                       P_G_OPRKND ok,
                       WORKING_DATE wd,
                       P_CONTRACT c
                 WHERE o.P_CONTRACT = c.P_CONTRACT
                   and c.G_FILIAL = G_Filial_
                   and o.P_G_OPRKND = ok.P_G_OPRKND
                   and ok.P_G_GROUP_OPRKND in (8,102,122,123)
                   and c.P_G_CONTRACT_STATUS = 5
                   and o.WORKING_DATE = wd.WORKING_DATE
                   and wd.WORK_DATE between Begin_Date_ and End_Date_;
            exception
              when NO_DATA_FOUND then
                 RESULT := 0;
            end;
        end if;

        RETURN RESULT;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;

    ---------------------------------------------------------------------------
function Get_Month_Name
-------------------------------------------------------------------------
-- Функция возвращает название месяца на заданном языке в заданном падеже
-------------------------------------------------------------------------
  (
  Month_    In Integer,
  Case_     In Integer,
  Language_ In SmallInt default 0
  )
return VarChar2 is
  Result G_MONTH.N1_E % type := '';
begin
  select Decode(Language_,
                0, Decode(Case_, 1, N1_R, 2, N2_R, 3, N3_R,
                                 4, N4_R, 5, N5_R, 6, N6_R, N1_R),
                1, Decode(Case_, 1, N1_K, 2, N2_K, 3, N3_K, 4, N4_K,
                                 5, N5_K, 6, N6_K, 7, N7_K, N1_K),
                2, N1_E,
                '')
    into Result
    from G_MONTH
   where G_MONTH = Month_;
  Return Result;
exception
  when others then
    return Result;
end;

function Get_PayOut_Official_Date
-------------------------------------------------------------------------
-- Функция возвращает дату изменения статуса таблицы выплаты
-------------------------------------------------------------------------
  (
  P_Claim_Pay_Out_ In P_CLAIM_PAY_OUT.P_CLAIM_PAY_OUT  % type,
  Status_          In P_CLAIM_PAY_OUT.P_G_CLAIM_STATUS % type
  )
return P_CLAIM_PAY_OUT_OFFICIAL.CONFIRM_DATE % type is
  Result P_CLAIM_PAY_OUT_OFFICIAL.CONFIRM_DATE % type;
begin
  select max(CONFIRM_DATE)
    into Result
    from P_CLAIM_PAY_OUT_OFFICIAL
   where P_CLAIM_PAY_OUT = P_Claim_Pay_Out_
     and P_G_CLAIM_STATUS = Status_;
  Return Result;
exception
  when others then
    return Result;
end;

function Get_Transfer_Official_Date
-------------------------------------------------------------------------
-- Функция возвращает дату изменения статуса таблицы переводам
-------------------------------------------------------------------------
  (
  P_Claim_Transfer_ In P_CLAIM_TRANSFER.P_CLAIM_TRANSFER  % type,
  Status_           In P_CLAIM_TRANSFER.P_G_CLAIM_STATUS  % type
  )
return P_CLAIM_TRANSFER_OFFICIAL.CONFIRM_DATE % type is
  Result P_CLAIM_TRANSFER_OFFICIAL.CONFIRM_DATE % type;
begin
  select max(CONFIRM_DATE)
    into Result
    from P_CLAIM_TRANSFER_OFFICIAL
   where P_CLAIM_TRANSFER = P_Claim_Transfer_
     and P_G_CLAIM_STATUS = Status_;
  Return Result;
exception
  when others then
    return Result;
end;


-- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ПЕНСИОННЫХ НАКОПЛЕНИИ НА ПОРТФЕЛЕ ДОГОВОРА. ПН НА ТЕК МОМЕНТ,
-- БЕЗ ОБРАБОТКИ ОШИБОК, ДЛЯ ИСПОЛЬЗОВАНИЯ В СЕЛЕКТАХ
FUNCTION GET_P_CONTRACT_PRTF_BALANCE(
    P_CONTRACT_    IN  P_CONTRACT.P_CONTRACT%TYPE,
    P_G_PORTFOLIO_ IN  P_G_PORTFOLIO.P_G_PORTFOLIO%TYPE
    ) RETURN NUMBER
IS
    RESULT        NUMBER;
    COURSE_       NUMBER;
--    OUTPUT_CU_    NUMBER;
BEGIN
  BEGIN

  SELECT NVL(SUM(COURSE), 0)
    INTO COURSE_
    FROM P_G_COURSE
   WHERE P_G_COURSE IN (SELECT MAX(CUR.P_G_COURSE)
                          FROM P_G_COURSE CUR
                         WHERE CUR.P_G_PORTFOLIO = P_G_PORTFOLIO_
                       );

    SELECT ROUND(NVL(SUM(PS.OUTPUT_CU), 0) * COURSE_, ADM.CONNECTION_PARAM.KZDIGIT)
      INTO RESULT
      FROM P_ACC PA,
           P_G_ACCKND PK,
           P_ACCOUNT_STATE PS
     WHERE PA.P_CONTRACT = P_CONTRACT_
       AND PA.G_ACCOUNT = PS.G_ACCOUNT
       AND PA.P_G_ACCKND = PK.P_G_ACCKND
       AND PK.P_G_PORTFOLIO = P_G_PORTFOLIO_
       AND PK.P_G_GROUP_ACCKND in (1, 11)
       AND PS.IS_LAST = 1;

  EXCEPTION
    WHEN OTHERS THEN
      RESULT := 0;
  END;
  RETURN(NVL(RESULT,0));
END;


-- ФУНКЦИЯ ПОЛУЧЕНИЯ СУММЫ ПОРОГА ДОСТАТОЧНОСТИ ИЗ ТАБЛИЦЫ P_G_SUFFICIENCY_LEVEL - СПРАВОЧНИК ПОРОГОВ ДОСТАТОЧНОСТИ ПО ВОЗРАСТАМ, С ИСТОРИЕЙ
FUNCTION GET_SUM_SUFFICIENCY_LEVEL(
  G_PERSON_       IN NUMBER,
  DATE_RECEPTION_ IN DATE
) RETURN NUMBER
IS
  AGE_     NUMBER;
  MAX_AGE_ NUMBER;
  MIN_AGE_ NUMBER;
  RESULT   NUMBER;
BEGIN
  -- ПОЛУЧИМ ВОЗРАСТ ВКЛАДЧИКА
  SELECT TRUNC(MONTHS_BETWEEN(NVL(DATE_RECEPTION_, SYSDATE), DT) / 12)
    INTO AGE_
    FROM MAIN.G_NAT_PERSON --(!) FROM MAIN.G_NAT_PERSON$$O
   WHERE G_PERSON = G_PERSON_;

  BEGIN
    SELECT MAX(PL.YRS), MIN(PL.YRS)
      INTO MAX_AGE_, MIN_AGE_	  -- Не исключено, что диапазон возрастов будет расширен или сужен (в 2021 было 20-59)
      FROM MAIN.P_G_SUFFICIENCY_LEVEL PL
     WHERE TRUNC(DATE_RECEPTION_) BETWEEN PL.K_DAY_START AND PL.K_DAY_END;
    SELECT PL.SUMMA
      INTO RESULT
      FROM MAIN.P_G_SUFFICIENCY_LEVEL PL
     WHERE TRUNC(DATE_RECEPTION_) BETWEEN PL.K_DAY_START AND PL.K_DAY_END
       AND PL.YRS = GREATEST(LEAST(AGE_, MAX_AGE_), MIN_AGE_);
  EXCEPTION
    WHEN OTHERS THEN
      RESULT := NULL;
  END;

  RETURN RESULT;
END;

-- ФУНКЦИЯ ВОЗВРАЩАЕТ ЗАДОЛЖЕННОСТЬ ОТЛОЖЕННОГО ИПН ПО ДОГОВОРУ/ВКЛАДЧИКУ
FUNCTION GET_SUMM_TAX_DEFERRAL(
  P_CONTRACT_       IN NUMBER,
  G_PERSON_         IN NUMBER
) RETURN NUMBER
IS
  RESULT       NUMBER;
  V_ERR_CODE   ADM.TYPES.TERR_CODE := 0;
  V_ERR_MSG    ADM.TYPES.TERR_MSG := '';
BEGIN
  RESULT := P_GET_SUMM_TAX_DEFERRAL(P_CONTRACT_    => P_CONTRACT_,
                                    G_PERSON_      => G_PERSON_,
                                    ERR_CODE       => V_ERR_CODE,
                                    ERR_MSG        => V_ERR_MSG);
  IF V_ERR_CODE != 0 THEN
    RESULT := 0;
  END IF;

  RETURN RESULT;
END;

-- ФУНКЦИЯ ВЫЧИСЛЕНИЯ ОСТАТКА ОТЛОЖЕННОГО ИПН ПО ДОГОВОРУ НА ДАТУ, БЕЗ ОБРАБОТКИ ОШИБОК, ДЛЯ ИСПОЛЬЗОВАНИЯ В СЕЛЕКТАХ
FUNCTION GET_SUMM_TAX_DEFERRAL_DATE(
  P_CONTRACT_    IN  P_CONTRACT.P_CONTRACT%TYPE,
  DATE_ID_       IN NUMBER,
  DATE_          IN DATE
) RETURN NUMBER
IS
  RESULT         NUMBER;
  WORKING_DATE_  NUMBER;
  -- 17.11.2025 Бычков  Спрячем долги по налогам после даты вступления в силу Налогового кодекса 01.01.2026
  --               отключили это сокрытие, чтобы нормально работать в опердатах 2025 из 2026 года
BEGIN
  BEGIN
    IF NVL(DATE_, TRUNC(SYSDATE)) >= TO_DATE(nvl(trim(Main.Get_System_Setup_By_Code('TAX_CODE_2026_DATE')), '01.01.2050'), 'DD.MM.YYYY')
      and 1 = 2   -- отключили это сокрытие, чтобы нормально работать в опердатах 2025 из 2026 года
    THEN
      RESULT := 0;
    ELSE
      IF DATE_ IS NOT NULL THEN
        SELECT MAX(W.WORKING_DATE)
          INTO WORKING_DATE_
          FROM WORKING_DATE W,
               P_TAX_DEFERRAL_STATE PS
         WHERE PS.P_CONTRACT = P_CONTRACT_
           AND PS.WORKING_DATE = W.WORKING_DATE
           AND W.WORK_DATE <= DATE_;
      ELSE
        SELECT MAX(PS.WORKING_DATE)
          INTO WORKING_DATE_
          FROM P_TAX_DEFERRAL_STATE PS
         WHERE PS.P_CONTRACT = P_CONTRACT_
           AND PS.WORKING_DATE <= DATE_ID_;
      END IF;

      SELECT SUM(PS.OUTPUT)
        INTO RESULT
        FROM P_TAX_DEFERRAL_STATE PS
       WHERE PS.P_CONTRACT = P_CONTRACT_
         AND PS.WORKING_DATE = WORKING_DATE_;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RESULT := 0;
  END;
  RETURN(NVL(RESULT,0));
END;

-- ФУНКЦИЯ ВЫЧИСЛЕНИЯ МРП НА НАЧАЛО ГОДА
FUNCTION GET_MRP_SUMM_BEG_OF_YEAR(
    DATE_        IN  DATE,
    ERR_CODE     OUT TYPES.TERR_CODE,
    ERR_MSG      OUT TYPES.TERR_MSG
    ) RETURN NUMBER
IS
  RESULT NUMBER;
BEGIN
  ERR_CODE := 0;
  ERR_MSG  := NULL;
  BEGIN
    SELECT G.VALUE
      INTO RESULT
      FROM G_MINIMAL_DESIGN_INDEX G
     WHERE G.G_PARAMETER = 1 AND
           G.K_DAY = (SELECT MIN(G2.K_DAY)
                        FROM G_MINIMAL_DESIGN_INDEX G2
                       WHERE G2.G_PARAMETER = 1 AND
                             TO_CHAR(G2.K_DAY, 'YYYY') = TO_CHAR(DATE_, 'YYYY')
                       );
  EXCEPTION
    WHEN OTHERS THEN
      ERR_CODE := SQLCODE;
      ERR_MSG  := 'ПОКАЗАТЕЛЬ "МРП" ЗА ТЕКУЩИЙ ГОД НЕ ВВЕДЕНА СПРАВОЧНИК "РАСЧЕТНЫХ ПОКАЗАТЕЛЕЙ"';
  END;
  RETURN(RESULT);
END;

-- ФУНКЦИЯ ВЫЧИСЛЕНИЯ МИНИМАЛЬНОЙ ЗАРАБОТНОЙ ПЛАТЫ НА НАЧАЛО ГОДА
FUNCTION GET_MIN_SALARY_SUM_BEG_OF_YEAR(
    DATE_      IN  DATE,
    ERR_CODE   OUT TYPES.TERR_CODE,
    ERR_MSG    OUT TYPES.TERR_MSG
    ) RETURN NUMBER
IS
  RESULT NUMBER;
BEGIN
  ERR_CODE := 0;
  ERR_MSG  := NULL;
  BEGIN
    SELECT G.VALUE
      INTO RESULT
      FROM G_MINIMAL_DESIGN_INDEX G
     WHERE G.G_PARAMETER = 3 AND
           G.K_DAY = (SELECT MIN(G2.K_DAY)
                        FROM G_MINIMAL_DESIGN_INDEX G2
                       WHERE G2.G_PARAMETER = 3 AND
                             TO_CHAR(G2.K_DAY, 'YYYY') = TO_CHAR(DATE_, 'YYYY')
                       );

  EXCEPTION
    WHEN OTHERS THEN
      ERR_CODE := SQLCODE;
      ERR_MSG  := 'ПОКАЗАТЕЛЬ "МИНИМАЛЬНОЙ ЗАРАБОТНОЙ ПЛАТА" ЗА ТЕКУЩИЙ ГОД НЕ ВВЕДЕНА СПРАВОЧНИК "РАСЧЕТНЫХ ПОКАЗАТЕЛЕЙ"';
  END;
  RETURN(RESULT);
END;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ МЕСЯЧНОГО НАЛОГОВОГО ВЫЧЕТА НА НАЧАЛО ГОДА (СОЗДАНА 28.12.2021 БЫЧКОВЫМ)
    -- до 31.12.2021 предоставлялся вычет в размере 1 МЗП
    --  с 01.01.2022 вычет применяемый к месячному доходу равен 14 * МРП
    FUNCTION GET_MONTH_DEDUCTION(
        DATE_      IN  DATE,
        ERR_CODE   OUT TYPES.TERR_CODE,
        ERR_MSG    OUT TYPES.TERR_MSG
        ) RETURN NUMBER
    IS
      RESULT NUMBER;
    BEGIN
      ERR_CODE := 0;
      ERR_MSG  := NULL;
      IF DATE_ < TO_DATE('01.01.2022', 'DD.MM.YYYY') THEN
        BEGIN
          SELECT G.VALUE
            INTO RESULT
            FROM G_MINIMAL_DESIGN_INDEX G
           WHERE G.G_PARAMETER = 3 AND G.K_DAY = (SELECT MAX(G2.K_DAY) FROM G_MINIMAL_DESIGN_INDEX G2
                                                   WHERE G2.G_PARAMETER = 3 AND TO_CHAR(G2.K_DAY, 'YYYY') = TO_CHAR(DATE_, 'YYYY'));
        EXCEPTION
          WHEN OTHERS THEN
            ERR_CODE := SQLCODE;
            ERR_MSG  := 'ПОКАЗАТЕЛЬ "МИНИМАЛЬНАЯ ЗАРАБОТНАЯ ПЛАТА" ОТСУТСТВУЕТ В СПРАВОЧНИКЕ "РАСЧЕТНЫЕ ПОКАЗАТЕЛИ" НА ' || TO_CHAR(DATE_, 'YYYY') || ' ГОД';
        END;
      ELSE
        -- 14.05.2022 Бычков М. Чтобы не рисковать, решил данную функцию изменить в соответствии с п. 30) (подпункт 1) пункта 1 статьи 346 переизложен)
        --  Измененная редакция НК РК с 01.01.2022:
        -- «Статья 345. Налоговый вычет по пенсионным выплатам и договорам накопительного страхования
        -- 1. К доходу в виде пенсионных выплат, подлежащему налогообложению, применяется налоговый вычет в следующих размерах:
        --  1) по выплатам, предусмотренным подпунктом 1) статьи 326 настоящего Кодекса, - в размере 14-кратного месячного расчетного показателя,
        --     установленного законом о республиканском бюджете и действующего на дату начисления дохода в виде пенсионной выплаты, за каждый месяц,
        --     за который осуществляется пенсионная выплата;
        --  2) по выплатам, предусмотренным подпунктом 2) статьи 326 настоящего Кодекса, - в размере 168-кратного месячного расчетного показателя,
        --     установленного законом о республиканском бюджете и действующего на дату начисления дохода в виде пенсионной выплаты.
        -- ...
        -- 30) подпункт 1) пункта 1 статьи 346 изложить в следующей редакции:
        --  «1) 14-кратный размер месячного расчетного показателя, установленного законом о республиканском бюджете и действующего на 1 января
        --      соответствующего финансового года. Стандартный вычет применяется за каждый календарный месяц.
        --      Общая сумма стандартного вычета за календарный год не должна превышать 168-кратный размер месячного расчетного показателя,
        --      установленного законом о республиканском бюджете и действующего на 1 января соответствующего финансового года;»
        BEGIN
          SELECT G.VALUE * 14
            INTO RESULT
            FROM G_MINIMAL_DESIGN_INDEX G
           WHERE G.G_PARAMETER = 1 AND TO_CHAR(G.K_DAY, 'DDMMYYYY') = '0101' || TO_CHAR(DATE_, 'YYYY');
        EXCEPTION
          WHEN OTHERS THEN
            ERR_CODE := SQLCODE;
            ERR_MSG  := 'ПОКАЗАТЕЛЬ "МИНИМАЛЬНЫЙ РАСЧЕТНЫЙ ПОКАЗАТЕЛЬ" ОТСУТСТВУЕТ В СПРАВОЧНИКЕ "РАСЧЕТНЫЕ ПОКАЗАТЕЛИ" НА ' || TO_CHAR(DATE_, 'YYYY') || ' ГОД';
        END;
      END IF;
      RETURN(RESULT);
    END;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ МЕСЯЧНОГО НАЛОГОВОГО ВЫЧЕТА НА НАЧАЛО ГОДА (СОЗДАНА 28.12.2021 БЫЧКОВЫМ)
    -- до 31.12.2021 предоставлялся вычет в размере 1 МЗП
    --  с 01.01.2022 вычет применяемый к месячному доходу равен 14 * МРП
    FUNCTION GET_MONTH_DEDUCTION_BEG_OF_YY(
        DATE_      IN  DATE,
        ERR_CODE   OUT TYPES.TERR_CODE,
        ERR_MSG    OUT TYPES.TERR_MSG
        ) RETURN NUMBER
    IS
      RESULT NUMBER;
    BEGIN
      ERR_CODE := 0;
      ERR_MSG  := NULL;
      IF DATE_ < TO_DATE('01.01.2022', 'DD.MM.YYYY') THEN
        BEGIN
          SELECT G.VALUE
            INTO RESULT
            FROM G_MINIMAL_DESIGN_INDEX G
           WHERE G.G_PARAMETER = 3 AND G.K_DAY = (SELECT MIN(G2.K_DAY) FROM G_MINIMAL_DESIGN_INDEX G2
                                                   WHERE G2.G_PARAMETER = 3 AND TO_CHAR(G2.K_DAY, 'YYYY') = TO_CHAR(DATE_, 'YYYY'));
        EXCEPTION
          WHEN OTHERS THEN
            ERR_CODE := SQLCODE;
            ERR_MSG  := 'ПОКАЗАТЕЛЬ "МИНИМАЛЬНАЯ ЗАРАБОТНАЯ ПЛАТА" ОТСУТСТВУЕТ В СПРАВОЧНИКЕ "РАСЧЕТНЫЕ ПОКАЗАТЕЛИ" НА ' || TO_CHAR(DATE_, 'YYYY') || ' ГОД';
        END;
      ELSE
        BEGIN
          SELECT G.VALUE * 14
            INTO RESULT
            FROM G_MINIMAL_DESIGN_INDEX G
           WHERE G.G_PARAMETER = 1 AND G.K_DAY = (SELECT MIN(G2.K_DAY) FROM G_MINIMAL_DESIGN_INDEX G2
                                                   WHERE G2.G_PARAMETER = 1 AND TO_CHAR(G2.K_DAY, 'YYYY') = TO_CHAR(DATE_, 'YYYY'));
        EXCEPTION
          WHEN OTHERS THEN
            ERR_CODE := SQLCODE;
            ERR_MSG  := 'ПОКАЗАТЕЛЬ "МИНИМАЛЬНЫЙ РАСЧЕТНЫЙ ПОКАЗАТЕЛЬ" ОТСУТСТВУЕТ В СПРАВОЧНИКЕ "РАСЧЕТНЫЕ ПОКАЗАТЕЛИ" НА ' || TO_CHAR(DATE_, 'YYYY') || ' ГОД';
        END;
      END IF;
      RETURN(RESULT);
    END;

    -- ФУНКЦИЯ ВЫЧИСЛЕНИЯ СУММЫ, ДОСТУПНОЙ ДЛЯ ПЕРЕВОДА В УИП С УКАЗАННОГО ИПС НА УКАЗАННУЮ ДАТУ (СОЗДАНА 17.04.2023 БЫЧКОВЫМ)
    FUNCTION GET_SUMM_AVAIL_FOR_UIP(P_CONTRACT_ IN NUMBER, DATE_ IN DATE) RETURN NUMBER IS
      RESULT_            NUMBER;
      CUR_               TP_PERSON_INDICATORS;
      C_KND_             NUMBER;
      G_PERSON_          NUMBER;
      R_C_               NUMBER;
      E_C_               NUMBER;
      E_M_               VARCHAR2(1024);

    BEGIN
      SELECT MIN(C.P_G_CONTRACT_KND), MIN(C.G_PERSON_RECIPIENT)
        INTO C_KND_, G_PERSON_
        FROM MAIN.P_CONTRACT C WHERE C.P_CONTRACT = P_CONTRACT_;
      IF C_KND_ IS NULL THEN RETURN(NULL); END IF;
      p_get_sum_sufficiency_level(g_person_               => G_PERSON_,
                                  work_date_              => DATE_,
                                  id_mode_                => 1,
                                  p_g_recipient_category_ => R_C_,
                                  cur                     => CUR_,
                                  err_code                => E_C_,
                                  err_msg                 => E_M_);
      SELECT NVL(MAX(A.SUMM), 0)
        INTO RESULT_
        FROM TABLE(CAST(CUR_ AS TP_PERSON_INDICATORS)) A
       WHERE A.CODE = TO_CHAR(700 + C_KND_);
      RETURN(RESULT_);
    END;

  FUNCTION fldPensionDate (vldDT IN DATE, vliG_Sex IN NUMBER) RETURN DATE IS
    vldResult DATE;
  BEGIN
    vldResult := ADD_MONTHS(vldDT, 12 * CASE when vliG_Sex in (1,2) THEN 63
                                       WHEN EXTRACT(YEAR FROM vldDT)<=1959 THEN 58
                                       WHEN EXTRACT(YEAR FROM vldDT)>=1969 THEN 63
                                ELSE 
                                  CASE EXTRACT(YEAR FROM vldDT)*100 + trunc(EXTRACT(MONTH FROM vldDT)/7)
                                    WHEN 196000 THEN 58.5
                                    WHEN 196001 THEN 59
                                    WHEN 196100 THEN 59.5
                                    WHEN 196101 THEN 60
                                    WHEN 196200 THEN 60.5
                                    WHEN 196700 THEN 61.5
                                    WHEN 196701 THEN 62
                                    WHEN 196800 THEN 62.5
                                    WHEN 196801 THEN 63
                                                ELSE 61 END END);
    RETURN vldResult;
                                                    
  END;


END PENSION_PACK;
-- CREATE OR REPLACE PUBLIC SYNONYM PENSION_PACK FOR MAIN.PENSION_PACK;
-- GRANT EXECUTE ON PENSION_PACK TO ADM WITH GRANT OPTION;
/
