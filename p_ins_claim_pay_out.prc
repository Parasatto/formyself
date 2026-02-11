CREATE OR REPLACE PROCEDURE p_ins_claim_pay_out(
   P_CLAIM_PAY_OUT_INITIAL_     in varchar2,                                         -- NUMBER                         Ссылка на исходное заявление на выплату (заполняется только для заявлений на устранение кредиторской задолженности, изменение банквоских реквизитов, доп соглашений о выплате)
   P_CONTRACT_                  in varchar2,                                         -- NUMBER NOT NULL
   G_PERSON_                    in varchar2,
   P_G_CLAIM_PAY_OUT_KND_       in P_CLAIM_PAY_OUT.P_G_CLAIM_PAY_OUT_KND%type,       -- NUMBER DEFAULT 1 NOT NULL      Ссылка на вид заявления
   P_G_PAY_OUT_SUB_TYPE_        in P_CLAIM_PAY_OUT.P_G_PAY_OUT_SUB_TYPE%type,        -- NUMBER ID                      подвида выплаты
   G_TYPE_PERIOD_               in P_CLAIM_PAY_OUT.G_TYPE_PERIOD%type,               -- NUMBER NOT NULL                Ссылка на справочник периодичности
   P_G_REGISTRATION_TYPE_       in P_CLAIM_PAY_OUT.P_G_REGISTRATION_TYPE%type,       -- NUMBER NOT NULL                Способ регистрации
   P_G_REGISTRATION_PLACE_      in P_CLAIM_PAY_OUT.P_G_REGISTRATION_PLACE%type,      -- NUMBER NOT NULL                Место регистрации (АП, ДК, Филиал)
   IS_SEND_MAIL_                in P_CLAIM_PAY_OUT.IS_SEND_MAIL%type,                -- NUMBER DEFAULT 0 NOT NULL      Признак отправки по почте (старое поле GETBYPOST или POSTTRANSFER?)
   DATE_PAPER_                  in P_CLAIM_PAY_OUT.DATE_PAPER%type,                  -- DATE DEFAULT sysdate NOT NULL  Дата составления заявления (дата заполнения на бумажном носителе старое поле CLAIMPAPERDATE)
   DATE_RECEPTION_              in P_CLAIM_PAY_OUT.DATE_RECEPTION%type,              -- DATE DEFAULT sysdate NOT NULL  Дата приема заявления (старое поле  CLAIMDATEGCVP ?)
   DATE_REGISTR_                in P_CLAIM_PAY_OUT.DATE_REGISTR%type,                -- DATE DEFAULT sysdate NOT NULL  Дата регистрации заявления в Фонде (старое поле CLAIMDATEREGISTR)
   HERITAGE_PERCENT_FORMAL_     in P_CLAIM_PAY_OUT.HERITAGE_PERCENT_FORMAL%type,     -- NUMBER                         процент наследования формальный
   HERITAGE_PERCENT_REAL_       in P_CLAIM_PAY_OUT.HERITAGE_PERCENT_REAL%type,       -- NUMBER                         признак ручного выставления пользователем HERITAGE_PERCENT_REAL
   HERITAGE_QUANTITY_           in P_CLAIM_PAY_OUT.HERITAGE_QUANTITY%type,           -- NUMBER                         количество заявлений в месяц по наследству
   PRIVILEGE_IS_HAVE_           in P_CLAIM_PAY_OUT.PRIVILEGE_IS_HAVE%type,           -- NUMBER(1,0) DEFAULT 0 NOT NULL признак наличия льготы
   PRIVILEGE_DATE_END_          in P_CLAIM_PAY_OUT.PRIVILEGE_DATE_END%type,          -- DATE                           дата окончания льготы
   P_G_ANALYTICTYPES_           in P_CLAIM_PAY_OUT.P_G_ANALYTICTYPES%type,           -- NUMBER                         Ссылка на тип аналитики
   P_G_ANALYTICCODES_           in P_CLAIM_PAY_OUT.P_G_ANALYTICCODES%type,           -- NUMBER                         Ссылка на код аналитики
   BANK_G_JUR_PERSON_           in P_CLAIM_PAY_OUT.BANK_G_JUR_PERSON%type,           -- NUMBER                         Банк. реквизиты -  ссылка на банк
   G_JUR_PERSON_ACC_            in P_CLAIM_PAY_OUT.G_JUR_PERSON_ACC%type,            -- NUMBER                         Ссылка на справочник счетов Банков (через нее можно выйти и на сам банк)
   BANK_IS_FOREIGN_             in P_CLAIM_PAY_OUT.BANK_IS_FOREIGN%type,             -- NUMBER(1,0)                    Банк. реквизиты -  признак иностранного банка (старое поле ISBANKNOTRESIDENT)
   BANK_BY_POST_                in P_CLAIM_PAY_OUT.BANK_BY_POST%type,                -- NUMBER(1,0) DEFAULT 0 NOT NULL Банк. реквизиты -  признак получения по почте (старое поле GETBYPOST или POSTTRANSFER?)
   BANK_IS_CARD_ACCOUNT_        in P_CLAIM_PAY_OUT.BANK_IS_CARD_ACCOUNT%type,        -- NUMBER(1,0) DEFAULT 0          Банк. реквизиты -  признак карточного счета (в базе Sybase такого поля нет хотя в интерфейсе есть)
   BANK_BIK_                    in P_CLAIM_PAY_OUT.BANK_BIK%type,                    -- VARCHAR2(20 BYTE)              Банк. реквизиты - БИК
   BANK_RNN_                    in P_CLAIM_PAY_OUT.BANK_RNN%type,                    -- VARCHAR2(12 BYTE)              Банк. реквизиты - РНН
   BANK_ACCOUNT_                in P_CLAIM_PAY_OUT.BANK_ACCOUNT%type,                -- VARCHAR2(50 BYTE)              Банк. реквизиты - Р/с банка (старое поле  PAYRKCACCOUNT)
   BANK_ACCOUNT_PERSONAL_       in P_CLAIM_PAY_OUT.BANK_ACCOUNT_PERSONAL%type,       -- VARCHAR2(50 BYTE)              Банк. реквизиты -  лицевой (карточный) счет получателя (старое поле  PAYPERSONALACCOUNT)
   BANK_IS_RECIPIENT_ACCOUNT_   in P_CLAIM_PAY_OUT.BANK_IS_RECIPIENT_ACCOUNT%type,   -- NUMBER(1,0)                    Банк. реквизиты -    Признак принадлежности счета (2 - получателя, 1-доверителя, 0-счет поверенного) (старое поле ISDOVACCOUNT)
   BANK_BRANCH_NAME_            in P_CLAIM_PAY_OUT.BANK_BRANCH_NAME%type,            -- VARCHAR2(350 BYTE)             Банк. реквизиты -  наименование отделения/филиала (старое поле  PAYBRANCHNAME)
   BANK_BRANCH_CODE_            in P_CLAIM_PAY_OUT.BANK_BRANCH_CODE%type,            -- VARCHAR2(20 BYTE)              Банк. реквизиты -  код отделения/филиала (старое поле  PAYBRANCHCODE)
   BANK_FOREIGN_KPP_            in P_CLAIM_PAY_OUT.BANK_FOREIGN_KPP%type,            -- VARCHAR2(20 BYTE)              Банк. реквизиты -  КПП иностранного банка (старое поле  PAYBANKKPP)
   BANK_FOREIGN_ACCOUNT_        in P_CLAIM_PAY_OUT.BANK_FOREIGN_ACCOUNT%type,        -- VARCHAR2(22 BYTE)              Банк. реквизиты -  корсчет иностранного банка (старое поле PAYRKC)
   BANK_NAME_                   in P_CLAIM_PAY_OUT.BANK_NAME%type,                   -- VARCHAR2(255 BYTE)             Банк. реквизиты -  наименование банка (старое поле PAYBANKNAME)
   G_CURRENCY_                  in P_CLAIM_PAY_OUT.G_CURRENCY%type,                  -- NUMBER                         Валюта платежа
   P_G_TRUSTEE_                 in P_CLAIM_PAY_OUT.P_G_TRUSTEE%type,                 -- NUMBER                         Ссылка на поверенного лица (поверенный может быть null, т.к. в заявлении они могут вбивать его вручную)
   WARRANT_NUMBER_              in P_CLAIM_PAY_OUT.WARRANT_NUMBER%type,              -- VARCHAR2(25 BYTE)              Номер доверенности (старое поле  WARRANTNUMBER)
   WARRANT_begin_DATE_          in P_CLAIM_PAY_OUT.WARRANT_begin_DATE%type,          -- DATE                           Дата доверенности  (старое поле  WARRANTDATE или DOVBIRTHDATE)
   WARRANT_END_DATE_            in P_CLAIM_PAY_OUT.WARRANT_END_DATE%type,            -- DATE                           Дата окончания доверенности (старое поле  WARRANTDATE или DOVBIRTHDATE)

   -- данные Получателя
   FM_                          in P_CLAIM_PAY_OUT.FM%type,                          -- VARCHAR2(30 BYTE)              Получатель - Фамилия
   NM_                          in P_CLAIM_PAY_OUT.NM%type,                          -- VARCHAR2(30 BYTE)              Получатель - Имя
   FT_                          in P_CLAIM_PAY_OUT.FT%type,                          -- VARCHAR2(30 BYTE)              Получатель - Отчество
   DT_                          in P_CLAIM_PAY_OUT.DT%type,                          -- DATE                           Получатель - Дата рождения
   RNN_                         in P_CLAIM_PAY_OUT.RNN%type,                         -- VARCHAR2(12 BYTE)              Получатель - РНН
   IDN_                         in P_CLAIM_PAY_OUT.IDN%type,                         -- VARCHAR2(12 BYTE)              Получатель - ИИН
   G_RESIDENTS_                 in P_CLAIM_PAY_OUT.G_RESIDENTS%type,                 -- NUMBER(*,0)                    Получатель - ID Резиденство
   G_COUNTRY_                   in P_CLAIM_PAY_OUT.G_COUNTRY%type,                   -- NUMBER                         Получатель - Страна
   G_SEX_                       in P_CLAIM_PAY_OUT.G_SEX%type,                       -- NUMBER                         Получатель - ID ПоловойПризнак
   ADDRESS_                     in P_CLAIM_PAY_OUT.ADDRESS%type,                     -- VARCHAR2(255 BYTE)             Получатель - Адресс
   MOBPHONERASS_                in P_CLAIM_PAY_OUT.MOBPHONERASS%type,                -- VARCHAR2(11 BYTE)              Мобильный телефон для рассылок
   EMAILRASS_                   in P_CLAIM_PAY_OUT.EMAILRASS%type,                   -- VARCHAR2(100 BYTE)             ПОЧТА ДЛЯ РАССЫЛКИ
   PHONE_                       in P_CLAIM_PAY_OUT.PHONE%type,                       -- VARCHAR2(40 BYTE)              Получатель - телефон
   G_ID_KIND_                   in P_CLAIM_PAY_OUT.G_ID_KIND%type,                   -- NUMBER                         Получатель - ID ВидУдостЛичности
   ID_SERIAL_                   in P_CLAIM_PAY_OUT.ID_SERIAL%type,                   -- VARCHAR2(15 BYTE)              Получатель - СерияДокумента
   ID_NUM_                      in P_CLAIM_PAY_OUT.ID_NUM%type,                      -- VARCHAR2(25 BYTE)              Получатель - НомерДокумента
   ID_DATE_                     in P_CLAIM_PAY_OUT.ID_DATE%type,                     -- DATE                           Получатель - ДатаВыдачиДокумента
   ID_ISSUER_                   in P_CLAIM_PAY_OUT.ID_ISSUER%type,                   -- VARCHAR2(150 BYTE)             Получатель - КемВыданДокумент
   IS_INCOMPETENT_              in P_CLAIM_PAY_OUT.Is_Incompetent%type,              -- NUMBER(1,0) DEFAULT 0          Признак - недееспособное лицо
   HERITAGE_IS_PERCENT_CORRECT_ in P_CLAIM_PAY_OUT.HERITAGE_IS_PERCENT_CORRECT%type, -- NUMBER(1,0) DEFAULT 0 NOT NULL признак ручного выставления пользователем HERITAGE_PERCENT_REAL

  P_REESTR_KZ_                  in varchar2 default null, -- реестр КЗ, если это заявление на устранение КЗ

  -- данные поверенного
   FMTrustee_                   in p_claim_pay_out.fmtrustee%type,                   -- VARCHAR2(30 BYTE)              Поверенный - Фамилия
   NMTrustee_                   in p_claim_pay_out.nmtrustee%type,                   -- VARCHAR2(30 BYTE)              Поверенный - Имя
   FTTrustee_                   in p_claim_pay_out.fttrustee%type,                   -- VARCHAR2(30 BYTE)              Поверенный - Отчество
   DTTrustee_                   in p_claim_pay_out.dttrustee%type,                   -- DATE                           Поверенный - Дата рождения
   AddressTrustee_              in p_claim_pay_out.addresstrustee%type,              -- VARCHAR2(255 BYTE)             адрес поверенного
   G_ID_KIND_Trustee_           in p_claim_pay_out.g_id_kindtrustee%type,            -- NUMBER                         Поверенный - ID ВидУдостЛичности
   ID_SERIAL_Trustee_           in p_claim_pay_out.id_serialtrustee%type,            -- VARCHAR2(15 BYTE)              Поверенный - СерияДокумента
   ID_NUM_Trustee_              in p_claim_pay_out.id_numtrustee%type,               -- VARCHAR2(25 BYTE)              Поверенный - НомерДокумента
   ID_DATE_Trustee_             in p_claim_pay_out.id_datetrustee%type,              -- DATE                           Поверенный - ДатаВыдачиДокумента
   ID_ISSUER_Trustee_           in p_claim_pay_out.id_issuertrustee%type,            -- VARCHAR2(150 BYTE)             Поверенный - КемВыданДокумент
   RNNTrustee_                  in P_CLAIM_PAY_OUT.Rnntrustee%type,                  -- VARCHAR2(12 BYTE)              Поверенный - РНН
   IDNTrustee_                  in P_CLAIM_PAY_OUT.Idntrustee%type,                  -- VARCHAR2(12 BYTE)              Поверенный - ИИН
  -- данные доверителя
   FMSettlor_                   in p_claim_pay_out.fmSettlor%type,                   -- VARCHAR2(30 BYTE)              доверитель - Фамилия
   NMSettlor_                   in p_claim_pay_out.nmSettlor%type,                   -- VARCHAR2(30 BYTE)              доверитель - Имя
   FTSettlor_                   in p_claim_pay_out.ftSettlor%type,                   -- VARCHAR2(30 BYTE)              доверитель - Отчество
   DTSettlor_                   in p_claim_pay_out.dtSettlor%type,                   -- DATE                           доверитель - Дата рождения
   G_ID_KIND_Settlor_           in p_claim_pay_out.g_id_kindSettlor%type,            -- NUMBER                         доверитель - ID ВидУдостЛичности
   ID_SERIAL_Settlor_           in p_claim_pay_out.id_serialSettlor%type,            -- VARCHAR2(15 BYTE)              доверитель - СерияДокумента
   ID_NUM_Settlor_              in p_claim_pay_out.id_numSettlor%type,               -- VARCHAR2(25 BYTE)              доверитель - НомерДокумента
   ID_DATE_Settlor_             in p_claim_pay_out.id_dateSettlor%type,              -- DATE                           доверитель - ДатаВыдачиДокумента
   ID_ISSUER_Settlor_           in p_claim_pay_out.id_issuerSettlor%type,            -- VARCHAR2(150 BYTE)             доверитель - КемВыданДокумент
   RNNSettlor_                  in P_CLAIM_PAY_OUT.RnnSettlor%type,                  -- VARCHAR2(12 BYTE)              доверитель - РНН
   IDNSettlor_                  in P_CLAIM_PAY_OUT.IdnSettlor%type,                  -- VARCHAR2(12 BYTE)              доверитель - ИИН
   AddressSettlor_              in P_CLAIM_PAY_OUT.ADDRESSSETTLOR%type default null, -- VARCHAR2(255 BYTE)             доверитель - Адрес
  --
   IS_PREDSTAVITEL_             IN P_CLAIM_PAY_OUT.IS_TRUSTEE_PREDSTAVITEL%TYPE,     -- NUMBER                         ПОВЕРЕННЫЙ - ЗАКОННЫЙ ПРЕДСТАВИТЕЛЬ
   G_RESIDENTS_TRUSTEE_         IN P_CLAIM_PAY_OUT.G_RESIDENTS_TRUSTEE%TYPE,         -- NUMBER(1,0) DEFAULT null       ПРИЗНАК РЕЗИДЕНСТВА ПОВЕРЕННОГО
   G_RESIDENTS_SETTLOR_         IN P_CLAIM_PAY_OUT.G_RESIDENTS_SETTLOR%TYPE,         -- NUMBER(1,0) DEFAULT null       ПРИЗНАК РЕЗИДЕНСТВА ПОВЕРЕННОГО ПРИЗНАК РЕЗИДЕНСТВА ДОВЕРИТЕЛЯ
   BANK_INTERMED_NAME_          IN P_CLAIM_PAY_OUT.BANK_INTERMED_NAME%TYPE,          -- VARCHAR2(255 BYTE)             НАИМЕНОВАНИЕ БАНКА-ПОСРЕДНИКА
   BANK_INTERMED_SWIFT_         IN P_CLAIM_PAY_OUT.BANK_INTERMED_SWIFT%TYPE,         -- VARCHAR2(20 BYTE)              SWIFT БАНКА-ПОСРЕДНИКА
   BANK_INTERMED_ACC_           IN P_CLAIM_PAY_OUT.BANK_INTERMED_ACC%TYPE,           -- VARCHAR2(30 BYTE)              СЧЕТ БАНКА-ПОСРЕДНИКА
   TRUST_OSNOVANIE_             IN P_CLAIM_PAY_OUT.TRUSTOSNOVAINE%TYPE,              -- NUMBER(1,0)                    Основание поверенного - доверенность (0), решение органа опеки (1)

  -- представитель юрлица
   FMJURPREDSTAVITEL_           in P_CLAIM_PAY_OUT.FMJURPREDSTAVITEL%TYPE,           -- VARCHAR2(30 BYTE)              Фамилия представителя юрлица
   NMJURPREDSTAVITEL_           in P_CLAIM_PAY_OUT.NMJURPREDSTAVITEL%TYPE,           -- VARCHAR2(30 BYTE)              Имя представителя юрлица
   FTJURPREDSTAVITEL_           in P_CLAIM_PAY_OUT.FTJURPREDSTAVITEL%TYPE,           -- VARCHAR2(30 BYTE)              Отчество представителя юрлица
   IDDOCPREDSTAVITEL_           in P_CLAIM_PAY_OUT.IDDOCPREDSTAVITEL%TYPE,           -- NUMBER                         документ представителя: 0 - Устав, 1 - Доверенность
   DOCNUMPREDSTAVITEL_          in P_CLAIM_PAY_OUT.DOCNUMPREDSTAVITEL%TYPE,          -- VARCHAR2(20 BYTE)              номер документа представителя
   DOCDATEPREDSTAVITEL_         in P_CLAIM_PAY_OUT.DOCDATEPREDSTAVITEL%TYPE,         -- DATE                           дата документа представителя
   APPOINTPREDSTAVITEL_         in P_CLAIM_PAY_OUT.APPJURPREDSTAVITEL%TYPE,          -- VARCHAR2(255 BYTE)             Должность представителя юр лица

  -- новые поля из ЗАЯВКИ №2, ПУНКТ 1, ТЕМЕКОВ А.А. 19.04.2016
   CARDNUM_                     in P_CLAIM_PAY_OUT.CARDNUM%TYPE,                     -- VARCHAR2(20 BYTE)               НОМЕР КАРТЫ
   SORTCODE_                    in P_CLAIM_PAY_OUT.SORTCODE%TYPE,                    -- VARCHAR2(20 BYTE)
   BANK_COUNTRY_                in P_CLAIM_PAY_OUT.BANK_COUNTRY%TYPE,                -- NUMBER(*,0)                     СТРАНА БАНКА БЕНЕФИЦИАРА
   FM_LAT_                      in P_CLAIM_PAY_OUT.FM_LAT%TYPE,                      -- VARCHAR2(30 BYTE)               ФАМИЛИЯ НА ЛАТИНИЦЕ
   NM_LAT_                      in P_CLAIM_PAY_OUT.NM_LAT%TYPE,                      -- VARCHAR2(30 BYTE)               ИМЯ НА ЛАТИНИЦЕ
   FT_LAT_                      in P_CLAIM_PAY_OUT.FT_LAT%TYPE,                      -- VARCHAR2(30 BYTE)               ОТЧЕСТВО НА ЛАТИНИЦЕ
   NO_FT_                       IN P_CLAIM_PAY_OUT.NO_FT%TYPE,                       -- NUMBER(*,0) DEFAULT 0           ОТМЕТКА "БЕЗ ОТЧЕСТВА", 0 - ОТМЕТКА НЕ СТОИТ, 1 - ОТМЕТКА СТОИТ
   NO_FT2_                      IN P_CLAIM_PAY_OUT.NO_FT2%TYPE,                      -- NUMBER(*,0) DEFAULT 0           ОТМЕТКА "БЕЗ ОТЧЕСТВА" ДЛЯ БЛАНКОВ, 0 - ОТМЕТКА НЕ СТОИТ, 1 - ОТМЕТКА СТОИТ

  -- ЗАДАЧА 98809, 27.11.2017 ТЕМЕКОВ АА.
  --  24.02.2025 OlzhasT по IS_HAVE_RIGHT_REG_OLD_LAW_ дефаулту 0 передаем
   IS_HAVE_RIGHT_REG_OLD_LAW_   IN P_CLAIM_PAY_OUT.IS_HAVE_RIGHT_REG_OLD_LAW%TYPE DEFAULT 0,   -- NUMBER(*,0) DEFAULT -1

  -- 13.03.2018 ТЕМЕКОВ АА ЗАЯВКА ХХ - УДАЛЕНИЕ ДС
   AMOUNT_                      IN P_CLAIM_PAY_OUT.AMOUNT%TYPE,                      -- NUMBER DEFAULT 0 NOT NULL       Годовая сумма к выплате (для доп соглашения), если Amount_Is_Manual = 1, то вкладчик сам ВЫБИРАЕТ сумму, иначе МАКСИМАЛЬНАЯ годовая сумма по закону на текущий год. Пересчитывается при смене года в процедуре построения графика P_CALC_GRF
   AMOUNT_IS_MANUAL_            IN P_CLAIM_PAY_OUT.AMOUNT_IS_MANUAL%TYPE DEFAULT 0,  -- NUMBER(1,0) DEFAULT 0 NOT NULL  Признак ручного ввода годовой суммы выпалты по пожеланию Вкладчика (для доп соглашения, аналог Sybase поле isClaimSum)


  P_INGOING_PARSED_P01_         IN VARCHAR2,                                         -- 26.03.2018 ТЕМЕКОВ АА ЗАДАЧА ХХ - НАДО СОХРАНЯТЬ ИСХОДЯЩИЙ УСПЕШНЫЙ ЗАПРОС В ГК
  IDN_CHILD_                    IN P_CLAIM_PAY_OUT.IDN%TYPE,                         -- 24.04.2018 ТЕМЕКОВАА ЗАДАЧА 167697 ЧИНГИС ПОПРОСИЛ СОХРАНЯТЬ ПОЛЕ "ИИН РЕБЕНКА"

  -- 02.05.2018 ТЕМЕКОВ АА ЗАДАЧА ХХ ПО ВЗАИМОДЕЙСТВИЮ С ГК
  mode_                         in integer ,  -- 0 - обычное создание заявления, 1 - создание через запрос ГК, 2 - через P_CREATE_CLAIM_PAY_EXTRA
  NUMBERGK_                     IN P_CLAIM_PAY_OUT.NUMBERGK%TYPE,            --VARCHAR2(50) Nullable = Y  Номер заявления на выплату принятого в ГК
  DATEGK_                       IN P_CLAIM_PAY_OUT.DATEGK%TYPE,                 --DATE  Nullable = Y  Дата принятия заявления на выплату
  G_DISTRICT_                   IN P_CLAIM_PAY_OUT.G_DISTRICT%TYPE,             --INTEGER Nullable = Y  Код региона обслуживания
  QUEUE_NUM_                    IN P_CLAIM_PAY_OUT.QUEUE_NUM%TYPE,              --INTEGER Nullable = Y  этап выплаты
  DATE_PAY_RESTART_             IN P_CLAIM_PAY_OUT.DATE_PAY_RESTART%TYPE,       --DATE  Nullable = Y  Месяц и год возобновления выплат, будет храниться как дата, просто первое число месяца, потом просто оперировать будет легче
  PHONE_PENS_                   IN P_CLAIM_PAY_OUT.PHONE_PENS%TYPE,             --VARCHAR2(40)  Nullable = Y  Домашний телефон
  PAYS_IS_STOPPED_GK_           IN P_CLAIM_PAY_OUT.PAYS_IS_STOPPED_GK%TYPE,     --INTEGER Nullable = Y  Признак приостановления выплаты ГК 1 - да, 0 -нет
  G_REASON_PAY_STOP_GK_         IN P_CLAIM_PAY_OUT.G_REASON_PAY_STOP_GK%TYPE,   --INTEGER Nullable = Y
  REASON_PAY_STOP_GK_           IN P_CLAIM_PAY_OUT.REASON_PAY_STOP_GK%TYPE,     --VARCHAR2(250) Nullable = Y  Причина приостановления выплаты ГК
  PAYS_IS_STOPPED_ENPF_         IN P_CLAIM_PAY_OUT.PAYS_IS_STOPPED_ENPF%TYPE,   --INTEGER Nullable = Y  Отказ ЕНПФ в осуществлении выплаты (да/нет)
  G_REASON_PAY_STOP_ENPF_       IN P_CLAIM_PAY_OUT.G_REASON_PAY_STOP_ENPF%TYPE, --INTEGER Nullable = Y  Причина отказа ЕНПФ в осуществлении выплат
  REASON_PAY_STOP_ENPF_         IN P_CLAIM_PAY_OUT.REASON_PAY_STOP_ENPF%TYPE,   --VARCHAR2(250) Nullable = Y  Причина отказа ЕНПФ в осуществлении выплаты
  G_OFFICIAL_PAY_STOPPED_       IN P_CLAIM_PAY_OUT.G_OFFICIAL_PAY_STOPPED%TYPE, --INTEGER Nullable = Y  Сотрудник ЕНПФ, инициировавший отказ
  IS_HAVE_TAX_DEDUCTION_        IN P_CLAIM_PAY_OUT.NUMBERGK%TYPE,               --INTEGER Nullable = Y  Право на вычет 12 МЗП по пенсионным выплатам, 1 - есть, 0 - нет
  P_INGOING_PARSED_PENS_        IN P_CLAIM_PAY_OUT.P_INGOING_PARSED_PENS%TYPE,  --NUMBER  Nullable = Y
  DATE_PAY_STOP_GK_             IN P_CLAIM_PAY_OUT.DATE_PAY_STOP_GK%TYPE,       --DATE  Nullable = Y  Дата приостановления ГК выплат

  G_PERSON_RECIPIENT_           IN  VARCHAR2 DEFAULT NULL,                      -- ИДЕНТИФИКАТОР ПОЛУЧАТЕЛЯ ВЫПЛАТ (ССЫЛКА НА ТАБЛИЦУ ВКЛАДЧИКОВ, ТАК КАК РЕШИЛИ, ЧТО ЛОБОЕ ФИЗ.ЛИЦО ИМЕЮЩЕЕ ОТНОШЕНИЕ К ПЕНС.СИСТЕМЕ ПОТЕНЦИАЛЬНО МОЖЕТ ЯВЛЯТЬСЯ НАШИМ ВКЛАДЧИКОМ)
  G_PERSON_TRUSTEE_             IN  VARCHAR2 DEFAULT NULL,                      -- ИДЕНТИФИКАТОР ПОВЕРЕННОГО (ССЫЛКА НА ТАБЛИЦУ ВКЛАДЧИКОВ, ТАК КАК РЕШИЛИ, ЧТО ЛОБОЕ ФИЗ.ЛИЦО ИМЕЮЩЕЕ ОТНОШЕНИЕ К ПЕНС.СИСТЕМЕ ПОТЕНЦИАЛЬНО МОЖЕТ ЯВЛЯТЬСЯ НАШИМ ВКЛАДЧИКОМ)
  G_PERSON_SETTLOR_             IN  VARCHAR2 DEFAULT NULL,                      -- ИДЕНТИФИКАТОР ДОВЕРИТЕЛЯ  (ССЫЛКА НА ТАБЛИЦУ ВКЛАДЧИКОВ, ТАК КАК РЕШИЛИ, ЧТО ЛОБОЕ ФИЗ.ЛИЦО ИМЕЮЩЕЕ ОТНОШЕНИЕ К ПЕНС.СИСТЕМЕ ПОТЕНЦИАЛЬНО МОЖЕТ ЯВЛЯТЬСЯ НАШИМ ВКЛАДЧИКОМ)

  ID_DATE_END_                  IN  P_CLAIM_PAY_OUT.ID_DATE_END%TYPE,
  ID_DATETRUSTEE_END_           IN  P_CLAIM_PAY_OUT.ID_DATETRUSTEE_END%TYPE,
  ID_DATESETTLOR_END_           IN  P_CLAIM_PAY_OUT.ID_DATESETTLOR_END%TYPE,
  P_LT_GBDFL_PERSON_DEP_        IN  VARCHAR2 DEFAULT NULL,
  P_LT_GBDFL_PERSON_REC_        IN  VARCHAR2 DEFAULT NULL,
  P_LT_GBDFL_PERSON_TRUSTEE_    IN  VARCHAR2 DEFAULT NULL,
  P_LT_GBDFL_PERSON_SETTLOR_    IN  VARCHAR2 DEFAULT NULL,

  PRIVILEGE_DATE_begin_         IN  DATE,                                        -- ДАТА НАЧАЛА ДЕЙСТВИЯ ЛЬГОТЫ СОГЛАСНО ДС3
  FIRST_MONTH_                  IN  NUMBER,                                      -- МЕСЯЦ ПЕРВОЙ ВЫПЛАТЫ СОГЛАСНО ДС3
  P_G_RELATION_DEGREE_          IN  NUMBER DEFAULT NULL,                         -- СТЕПЕНЬ РОДСТВА (ЗАПОЛНЯЕТСЯ ТОЛЬКО ДЛЯ ЗАЯВЛЕНИИ НА ПОГРЕБЕНИЕ)
  IS_HAVE_RELATION_DEGREE_      IN  NUMBER DEFAULT NULL,                         -- ПРИЗНАК НАЛИЧИЯ/ПОДТВЕРЖДЕНИЯ СТЕПЕНИ РОДСТВА (0-НЕ ПОДТВЕРЖДЕНО, 1-ПОДТВЕРЖДЕНО)

  g_residents_country_          IN NUMBER DEFAULT NULL,
  do_commit_                    IN  number default 1,
  P_CLAIM_PAY_OUT_              out varchar2, --P_CLAIM_PAY_OUT.P_CLAIM_PAY_OUT%type,
  Err_Code                      OUT TYPES.TErr_Code,
  Err_Msg                       OUT TYPES.TErr_Msg
)
IS
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- Создание заявления. Реестр создается на этапе отправки в ЦА
  -- Признак Резидент/Нерезидент и страну меняем в таблице G_NAT_PERSON на
  -- тот что ставится в заявлении, т.к. другой возможности изменения признака нет.
  -- Причем изменение признака не сохраняется в истории
  --
  -- Эта же процедура используется для создания заявления на устранение КЗ и на изменение БР.
  -- Схема такова: если P_G_CLAIM_PAY_OUT_KND_ in (2,3) то создаю точную копию текущего заявления
  -- с изменением соответсвующих параметров, и отправляю текущее заяв-е в историю.
  --
  -- Если заводится заявление на устранение КЗ, то обновляю поле P_CLAIM_PAY_OUT в таблице P_REESTR_KZ,
  -- и меняю данному реестру статус на 6 (Сформированно новое заявление)
  --
  -- Парится не стал с наворотами, сделал через IF, для простоты дальнейшего сопровождения
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- История изменений:
  -- Дата        Кто             Comments  где изменялось
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- 01.04.2011  Темеков А.А.    Создано
  -- 10.10.2013  ТИМУР И СЕРИК               эту проверку сказали поставить ,  ТОЛЬКО ДЛЯ РАЗОВОЙ ВЫПЛАТЫ
  -- 02.03.2015  Темеков А.А.                В СООТВЕТСТВИИ С ЗАЯВКОЙ НА САЙТЕ ТЕХПОДДЕРЖКИ №7196
  -- 17.08.2016  ТЕМЕКОВ А.А.                ЗАДАЧА 130200 КОММЕНТ ЧИНГИСА НАДО ЗАТИРАТЬ ДАННЫМИ ИЗ ВКЛАДЧИКА ПРИ СТАТУСАХ 6, -6, 0, 1, 3,
  -- 09.02.2017  ТЕМЕКОВ АА.                 ЗАДАЧА 178725, ЕСЛИ ПРОИСХОДИТ ОШИБКА В P_CLOSE_ADDSH_PAY_OUT, ТО ОНА ПРОГЛАТЫВАЛАСЬ
  -- 23.10.2017  ТЕМЕКОВ АА                  ЗАДАЧА 100796  , ПОЯВИЛСЯ НОВЫЙ ВЫЧИСЛЯЕМЫЙ ПАРАМЕТР
  -- 16.11.2017  ТЕМЕКОВ АА.,                ЗАДАЧА 97514, ДОБАВЛЕНА ПРОВЕРКА НА ЗАЧИСЛЕНИЕ КЗ НА ИПС
  -- 16.11.2017  ТЕМЕКОВ АЙДЫН               ЗАДАЧА 97514, номер надо искать если это КЗ
  -- 27.11.2017  ТЕМЕКОВ АА.,                ЗАДАЧА 98809, ДОБАВЛЕН НОВЫЙ ВХОДНОЙ ПАРАМЕТР, КОТОРЫЙ ВСТАВЛЯЕТСЯ В ТАБЛИЦУ
  -- 07.12.2017  Omirbaev Timur              При вычислении годовой суммы разбил на две ветки, для старого законодательства и для нового с 2018г. IS_HAVE_RIGHT_REG_OLD_LAW_=0
  -- 07.12.2017  Сарсенбаев, Омирбаев        ЗАДАЧА 98809, для заявлений по новому законодательству, действующему с 01.01.2018
  -- 21.12.2017  ТемековА                    Задача 98809, теперь в КЗ можно менять вид выплаты - льгота/нельгота, pnt 05b
  -- 13.03.2018  ТЕМЕКОВ АА                  ЗАДАЧА ХХ ДС УДАЛЯЕТСЯ, ПОЛЕ AMOUNT_IS_MANUAL ПЕРЕНОСИТСЯ В ЗАЯВЛЕНИЕ
  -- 26.03.2018  ТЕМЕКОВ АА                  ЗАДАЧА ХХ - НАДО СОХРАНЯТЬ ИСХОДЯЩИЙ УСПЕШНЫЙ ЗАПРОС В ГК
  -- 24.04.2018  ТЕМЕКОВАА                   ЗАДАЧА 167697 ЧИНГИС ПОПРОСИЛ СОХРАНЯТЬ ПОЛЕ "ИИН РЕБЕНКА"
  -- 02.05.2018  ТЕМЕКОВ АА                  ЗАДАЧА ХХ ПО ВЗАИМОДЕЙСТВИЮ С ГК
  -- 05.05.2018  AnvarT                      Добавлена проверка на валидность ИБАН, запрос идет через вебсервис в случае ошибки записывается в p_claim_po_comment
  -- 25.05.2018  AnvarT                      Добавлена проверка на валидность ИБАН, по признаку принадлежности счета
  -- 29.05.2018  Нурсултанова А.             Добавила проверку на ин. банк
  -- 06.06.2018  AidarA                      ИИН подтягивается получателя, а должен поверенного, в зависимости от поля     №39690
  -- 08.06.2018  temekov aa                  Блок AnvarT отключен, если это создание заявления через ГК
  -- 12.06.2018  temekov aa                  Данными вкладчика заявление не перетирается, если заявление создается через ГК
  -- 15.06.2018  Темеков АА                  ЗАДАЧА 192926 - надо поставить пакетную переменную, чтобы при вычислении годовой суммы вкладчику было видно что заявление создает гк
  -- 22.06.2018  Темеков АА                  Задача 192926 - надо ДС и для ТД договоров создавать
  -- 26.04.2019  ТЕМЕКОВ АА,                 ЗАДАЧА 330091 - ЕСЛИ ЗАЯВЛЕНИЕ СОЗДАЕТСЯ ИЗ ПРОЦЕДУРЫ P_JOB_CLOSE_CONTRACT, ТО НУЖНО ИСПОЛЬЗОВАТЬ ВХОДНЫЕ ДАТЫ
  -- 10.06.2019  ТЕМЕКОВ АА                  ЗАДАЧА 361202, ПОСТАВИТЬ КОСТЫЛЬ ПО ДОГОВОРУ 9935285
  -- 23.10.2019  МАМЕТОВ С.А.                ПО ЗАДАЧЕ ДЕТЕЙ ИНВАЛИДОВ ПЕРЕНОСИМ ИЗ ВРЕМЕННОЙ ТАБЛИЦЫ P_LT_CLAIM_CHILD_INVALID# В P_LT_CLAIM_CHILD_INVALID
  -- 22.01.2020  МАМЕТОВ С.А.                ПО ЗАДАЧЕ В БИТРИКСЕ №475259 "КАСАТЕЛЬНО ЗАЯВЛЕНИЯ НА ВЫПЛАТУ В ЧАСТИ ВЕРИФИКАЦИИ ДАННЫХ ВКЛАДЧИКА
  --                                         (ПОЛУЧАТЕЛЯ ПЕНСИОННЫХ ВЫПЛАТ)/ЗАКОННОГО ПРЕДСТАВИТЕЛЯ/ПОВЕРЕННОГО ЛИЦА С ГБД ФЛ" ДОБАВИЛ ДОПОЛНИТЕЛЬНЫЕ ПАРАМЕТРЫ, ИТЕНТИФИКАТОРЫ ПОЛУЧАТЕЛЯ/ПОВЕРЕННОГО/ДОВЕРИТЕЛЯ
  -- 22.02.2020  МАМЕТОВ С.А.                ПО ЗАМЕЧАНИЯМ АУДИТОРОВ, ЗАДАЧА В БИТРИКСЕ № 406100, БЫВАЮТ СЛУЧАЙ, КОГДА ВОЗВРАТ ВЫПЛАТ ПО ВКЛАДЧИКУ ПРИХОДИТ В ОДИН МЕСЯЦ ЗА РАЗНЫЕ ПЕРИОДЫ
  --                                         ТАКИМ ОБРАЗОМ У НАС ОБРАЗУЮТСЯ ДВЕ ЗАПИСИ В РЕЕСТРЕ КЗ ПО ВЫПЛАТАМ. ПРИМЕР ИИН 920120301191. ПОЛЬЗОВАТЕЛЮ В ТАКОМ СЛУЧАЕ ПРИХОДИТСЯ ДВА РАЗА ВЫЗЫВАТЬ ВКЛАДЧИКА, ЧТО ВЛЕКЕТ С
  --                                         СОБОЙ РЕПУТАЦИОННЫЕ РИСКИ. ЧТО БЫ ПОЛЬЗОВАТЕЛЬ В ТАКОМ СЛУЧАЕ МОГ ЗАВЕСТИ ДВА ЗАЯВЛЕНИЯ ЗА ОДИН РАЗ, НАПИСАЛ УСЛОВИЕ НИЖЕ. ТАКОЕ РЕШЕНИЕ БЫЛО ПРИНЯТО ВСЕМИ ПРИ ОБСУЖДЕНИИ В ДУИОПА
  --                                         ТАКЖЕ ЗА ТАКОЙ ВАРИАНТ БЫЛИ НЕ ПРОТИВ И АНАЛИТИКИ ДИТ. НО В ЦЕЛОМ ВСЕ ПОНИМАЮТ, ЧТО ЭТО НЕ САМЫЙ КРАСИВЫЙ И ВЕРНЫЙ ПУТЬ РЕШЕНИЯ ПРОБЛЕМЫ, НО ОН САМЫЙ БЫСТРЫЙ.
  -- 05.03.2020  МАМЕТОВ С.А.                ПО ЗАДАЧЕ В БИТРИКСЕ № 489217 "ЗАЯВКА №188. 'КАСАТЕЛЬНО ЗАЯВЛЕНИЯ НА ВЫПЛАТУ В ЧАСТИ ВЕРИФИКАЦИИ ДАННЫХ
  --                                         ВКЛАДЧИКА (ПОЛУЧАТЕЛЯ ПЕНСИОННЫХ ВЫПЛАТ)/ЗАКОННОГО ПРЕДСТАВИТЕЛЯ/ПОВЕРЕННОГО ЛИЦА С ГБД ФЛ" ДОБАВИЛ УСЛОВИЕ "- ПО ЗАЯВЛЕНИЯМ ПО ВЫЕЗДУ УБРАТЬ ОБНОВЛЕНИЕ
  --                                         В ЗАЯВЛЕНИИ ДАННЫХ ПОЛУЧАТЕЛЯ В АВТОМАТИЧЕСКОМ РЕЖИМЕ НА СТАТУСАХ РП (-6, 6) И ЦА (0, 1, 3) ПРИ ОБНОВЛЕНИИ КАРТОЧКИ КЛИЕНТА (ПО АНАЛОГИИ С ЗАЯВЛЕНИЯМИ ПО СМЕРТИ)"
  -- 06.05.2020  МАМЕТОВ С.А.                ПО ЗАДАЧЕ В БИТРИКСЕ №512143 ДС № 2 И ДС № 3 К СОГЛАШЕНИЮ О ВЗАИМОДЕЙСТВИИ С ГК: ФУНКЦИОНАЛ ПО ПРИМЕНЕНИЮ НАЛОГОВОГО ВЫЧЕТА К
  --                                         ПЕНСИОННЫМ ВЫПЛАТАМ ПО ВОЗРАСТУ ЧЕРЕЗ ГК (PENS). 48. ОСУЩЕСТВЛЕНИЕ ВЫПЛАТ ЧЕРЕЗ ГК В СООТВЕТСТВИИ С УСТАНОВЛЕННЫМ ГК ГРАФИКОМ ПЕНСИОННЫХ ВЫПЛАТ
  --                                         (В ЧАСТИ ИСКЛЮЧЕНИЯ ОСУЩЕСТВЛЕНИЯ ПЕРВОЙ ВЫПЛАТЫ В ТЕЧЕНИЕ 10 РАБОЧИХ ДНЕЙ, В СЛУЧАЕ ИЗМЕНЕНИЙ В ПРАВИЛА 1042)
  -- 27.08.2020  EKOPYLOV                    ПО ЗАДАЧЕ HTTP://ENPF24.KZ/WORKGROUPS/GROUP/40/TASKS/TASK/VIEW/521411/,
  --                                         ПРИ СОЗДАНИИ В РУЧНУЮ ЗАЯВЛЕНИЯ НА ВЫПЛАТУ ПО ДОГОВОРАМ ДВП ПОЛЕ G_PERSON_RECIPIENT_ НЕ ПЕРЕДАЕТСЯ,
  --                                         СДЕЛАЛ ПРОВЕРКУ ЕСЛИ ЭТО ПОЛЕ ПУСТОЕ, ТО ПРОСТАВЛЯЕМ ХОЗЯИНА ДОГОВОРА ПО КОТОРОМУ ДЕЛАЕТЬСЯ ЗАЯВЛЕНИЕ
  -- 15.10.2020  МАМЕТОВ С.А.                ПО РАБОТЕ СОВМЕСТНОГО ПРИКАЗА, ИЗЪЯТИИ СПРАВОК О СМЕРТИ, БЫЛИ ДОБАВЛЕНЫ ПАРАМЕТРЫ P_G_RELATION_DEGREE_ И IS_HAVE_RELATION_DEGREE_ В ПРОЦЕДУРУ
  -- 19.10.2020  EKOPYLOV                    ПО НЕ РЕЗИДЕНТАМ НЕ НАДО ПРОСТАВЛЯТЬ G_PERSON_RECIPIENT , Т.К. ИХ НЕТ В НАШЕЙ БАЗЕ. ЗАДАЧА HTTP://ENPF24.KZ/WORKGROUPS/GROUP/40/TASKS/TASK/VIEW/551090/
  -- 13.11.2020  МАМЕТОВ С.А.                HTTP://ENPF24.KZ/WORKGROUPS/GROUP/49/TASKS/TASK/VIEW/556960/
  --                                         ТРЕБОВАНИЯ ГУЛЬНАРЫ СУЛЕЙМЕНОВЫ "СВЕТА, ОТКРОЙТЕ ДОСТУП НА ФАКТИЧ. В КЗ!!! ЭТО ДАЖЕ ПО УМОЛЧАНИЮ ДОЛЖНО БЫТЬ, НАСЛЕДНИКОВ НИКАК БЕЗ ФАКТИЧ. НЕВОЗМОЖНО ВЫПЛАТИТЬ.
  --                                         ПРЕДСТАВЬ, ЧТО КЗ ИМЕЕТСЯ НЕОТРАБОТАННАЯ И ПОСТУПАЕТ ЕЩЕ ВЗНОСЫ. ДУИОПА РАСЧЕТ СДЕЛАЕТ. КАК ПО ТВОЕМУ ПРОСТАВЛЯТЬ В КЗ ФАКТИЧ.?
  --                                         ТЕМ БОЛЕЕ ЩАС ДОВЫПЛАТЫ ДОЛЕВИКАМ НА КЗ ВОЗВРАЩАЮТСЯ. ТАМ ВЕЗДЕ ФАКТИЧ. УКАЗАНЫ."
  -- 04.01.2021  МАМЕТОВ С.А.                ПОСЛЕ РАЗЪЯСНЕНИИ КГД КАСАТЕЛЬНО УЧЕТА ОТЛОЖЕННОГО ИПН ИЗМЕНИЛИСЬ РАСЧЕТЫ, ИЗМЕНИЛСЯ ПОДХОД К УЧЕТУ ОТЛОЖЕННОГО ИПН
  -- 21.06.2022  Y.Syunyakova                Задача №615906 Реестр на выплату (от Бильданова Фарида Якубовна)
  --                                         При вводе заявления на Выплату по решению суда, независимо от выбранного способа подачи заявления, в связи
  --                                         с Выплатой по решению суда Ю.Л. (115056) поля Дата составления и Дата приема заявления сделать активными для редактирования.
  -- 10.07.2022: Миреев А.                   Задача №819003 Модернизация ИС ИАИС-2 ПУПН. Заявка №317. 'Разработка функционала автоматического формирования бланка – согласия законного представителя на подачу несовершеннолетним лицом заявления о назначении пенсионных выплат'
  --                                         в форме заявления на выплату Pay_ClaimForm - во вкладке "Данные доверителя" сказали сделать новое поле "Адрес", и данные с этого поля должны храниться в заявлении.
  --                                         в таблице P_CLAIM_PAY_OUT - добавил новое поле ADDRESSSETTLOR VARCHAR2(255)
  --                                         Кузнецова Светлана Митрофановна написал:
  --                                         1) в электронной форме заявления:
  --                                         - становится активной вкладка "Данные доверителя" с автоматическим выставлением новой отметки "Согласие законного представителя" (недоступна для ручного ввода) и нового поля "Адрес" (доступного только для способа подачи "Лично";
  --                                         Добавил новый параметр AddressSettlor_
  -- 31.08.2022  Y.Syunyakova                Заявка 319 в MAIN.M__DECL.PL_CHECKDECLARE добавлен параметр
  -- 07.10.2022  Миреев А.                   pnt 010A Задача Заявка №327. 'Уведом УИП при регистрации заявления на выплату'
  --                                         При наличии у вкладчика (получателя) накоплений в УИП и поступлении в ЕНПФ заявления на выплату в связи: с погребением, наследством, решением суда, инвалидностью, ПМЖ, реализовать
  --                                         в ИАИС-2 функционал по автоматическому формированию и отправке в УИП и ДУОПА Уведомления о передаче пенсионных активов. Уведомление о передаче пенсионных активов при поступлении в ЕНПФ
  --                                         заявления на выплату в связи: с погребением, наследством, решением суда, инвалидностью, ПМЖ необходимо автоматически формировать и отправлять в день регистрации заявления
  --                                         на выплату, на электронные адреса ответственных лиц УИП и ДУОПА, по аналогии с реализованным Уведомлением (СЗ № ГКОА-17113 от 06.05.2022г.), с
  --                                         указанием предварительной суммы, в сумме находящейся в УИП на операционную дату подачи заявления и предварительной даты передачи ПА из УИП в УИП/НБРК – 2-й рабочий
  --                                         день от даты регистрации заявления на выплату. Кроме этого, необходимо установить контроль на заявления по выплатам с наличием накоплений в УИП при заполнении таблицы: Выплаты –
  --                                         Выплаты на текущую дату. В случае наличия ПН в УИП данные заявления выпадают в ошибочные с причиной: имеются накопления в УИП.
  -- 20.02.2023  Тайканов Е.Р.               В рамках проекта Доставка пенсий из стран ЕАЭС, для соответствующего типа контракта(20) исключил проверку на наличие остатка на счета
  -- 29.03.2023  МИРЕЕВ А.
  -- 07.06.2023  AnvarT                      Чуть подравнял, и поправил закрытие
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- 25.07.2023  Миреев А. Задача №942206    Разработка. Модернизация ИС ИАИС-2 ПУПН. Заявка №361. 'Доработка функционала получения и хранения цифровых документов при приеме заявления на выплату/возмещение ИПН'
  --                                         вставку в P_CLAIM_PAY_OUT_ATTACH_DOC вынес из k_insert_attached_doc сюда, для реализации ЦД в выплатах
  -- 20.02.2023  Тайканов Е.Р.               Задача КП Битрикс №961454 Если создаем заявление через модуль довыплат, но не нужно рекурсивно досоздавать заявления для других видов договоров.
  --                                         Для этого модуль довыплат передает mode_ = 2. Из за этого пришлось во всем коде if MODE_ = 0 then заменить на MODE_ != 1 then
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- 11.01.2024  Olzhast                     Добавил сохранение дополнительной инофрмации по анкете заявлению ЕАЭС
  -- 31.01.2024  OlzhasT                     Подправил заявка на техподдержку №1018664
  -- 02.04.2024  Olzhast                     Добавил сохранение дополнительной инофрмации по анкете заявлению ЕАЭС, доп поле
  -- 03.06.2024  Olzhast                     Добавил сохранение дополнительной инофрмации по анкете заявлению ЕАЭС, Person
  -- 15.08.2024  OlzhasT                     Добавил в исключение Анкету заявление
  -- 10.12.2024  Миреев А. п.3               Плана ДЦ на 3 и 4 кв.2024г. - Реализация алгоритмов замораживания операций по переводу / выплате накоплений физического лица или его представителя или получателя (погребение) или наследника, включенных в Перечни
  -- 10.01.2025  Тайканов Е.Р.               Конроль заявления на АВЗ
  --                                         https://enpf24.kz/company/personal/user/2337/tasks/task/view/1162461/
  -- 23.01.2025  Тайканов Е.Р.               Убрал ограничение при сохранении согласяния на сбор и обработку персональных данных при указании паспорта иностранного гражданина
  --                                         https://enpf24.kz/company/personal/user/1667/tasks/task/view/1121660/
  -- 07.02.2025  AnvarT                      Чуть дополнил протоколы
  -- 24.02.2025  OlzhasT                     по IS_HAVE_RIGHT_REG_OLD_LAW_ передаем 0 по заявлениям ЕАЭС Задача №1170835
  -- 03.07.2025  Y.Kisseleva                 pnt_ := '000' По заявлению на погребение при Запрос в ЗАГС "Не подтверждено"  и отсутствии бумаж. скан по типу "ДОКУМЕНТЫ, ПОДТВЕРЖДАЮЩИЕ РОДСТВЕННЫЕ СВЯЗИ"
  -- 15.07.2025  Тайканов Е.Р.               Доработал блок сохранения согласия. Если заявление подано через ЛК, то согласие на по ЭЦП.
  -- 03.09.2025  Y.Kisseleva                 логирование  pnt_ := '07'
  -- 04.09.2025  Y.Kisseleva                 запись в таблицу логирование раскоментарила 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ProcName                            constant  Types.TProc_Name :='P_INS_CLAIM_PAY_OUT';
  pnt_                                varchar2(5);
  CLAIM_NUM_                          p_claim_pay_out.claim_num%type := NULL;
  p_claim_pay_out__                   P_CLAIM_PAY_OUT.P_CLAIM_PAY_OUT%type;
  sumremain_                          P_CLAIM_PAY_OUT.Sumremain%type := 0;
  G_JUR_PERSON_ACC__                  P_CLAIM_PAY_OUT.G_JUR_PERSON_ACC%type := G_JUR_PERSON_ACC_;
  P_G_PAY_OUT_TYPE_                   P_G_PAY_OUT_TYPE.P_G_PAY_OUT_TYPE%TYPE;
  IS_PART_                            P_G_PAY_OUT_SUB_TYPE.P_G_PAY_OUT_SUB_TYPE%TYPE;  -- 13.03.2018  ТЕМЕКОВ АА      ЗАДАЧА ХХ ДС УДАЛЯЕТСЯ, ПОЛЕ AMOUNT_IS_MANUAL ПЕРЕНОСИТСЯ В ЗАЯВЛЕНИЕ

  -- 02.03.2015  Темеков А.А.    В СООТВЕТСТВИИ С ЗАЯВКОЙ НА САЙТЕ ТЕХПОДДЕРЖКИ №7196
  --1) режим «По почте» отключен – Дата составления заявления, Дата приема заявления, Дата регистрации в Фонде – не редактируемая, по умолчанию необходимо заполнять текущей системной датой рабочей станции, но в хранимой процедуре при первичном сохранении заявления необходимо принудительно перетирать текущей календарной датой сервера;
  --2) режим «По почте» включен:
  --   Дата составления заявления, Дата приема заявления редактируемая, по умолчанию заполнять текущей системной датой рабочей станции, при сохранении заявления указанные даты не должны перетираться;
  --   Дата регистрации в Фонде – не редактируемая, по умолчанию необходимо заполнять текущей системной датой рабочей станции, но в хранимой процедуре при сохранении заявления необходимо принудительно перетирать текущей календарной датой сервера.
  DATE_PAPER__                        P_CLAIM_PAY_OUT.DATE_PAPER%type := SYSDATE;
  DATE_RECEPTION__                    P_CLAIM_PAY_OUT.DATE_RECEPTION%type := SYSDATE;  --TRUNC(SYSDATE);  ЗАДАЧА 43365 СОХРАНЯТЬ ВРЕМЯ ТЕПЕРЬ
  DATE_REGISTR__                      P_CLAIM_PAY_OUT.DATE_REGISTR%type := SYSDATE;    --TRUNC(SYSDATE);  ЗАДАЧА 43365 СОХРАНЯТЬ ВРЕМЯ ТЕПЕРЬ
  NUM_                                NUMBER;

  -- amount_ заполняю всегда (только для заявления на выплату), если заявление будет без допсоглашения (т.е. разовая выплата)
  -- буду брать значения из Тиминой функции
  amount__                            P_CLAIM_PAY_OUT.Amount%type := 0;  -- 13.03.2018  ТЕМЕКОВ АА      ЗАДАЧА ХХ ДС УДАЛЯЕТСЯ, ПОЛЕ AMOUNT_IS_MANUAL ПЕРЕНОСИТСЯ В ЗАЯВЛЕНИЕ
  P_CLAIM_PAY_OUT_INIT_CH_            P_CLAIM_PAY_OUT.P_CLAIM_PAY_OUT%TYPE;      -- ЗАДАЧА 43365 - ИСХОДНОЕ ЗАЯВЛЕНИЕ ПРИ СОЗДАНИИ ЗАЯВЛЕНИЯ НА ИЗМЕНЕНИЕ РЕКВИЗИТОВ
  GPERSON_REC                         G_NAT_PERSON%ROWTYPE;    -- 17.08.2016  ТЕМЕКОВ А.А.    ЗАДАЧА 130200 КОММЕНТ ЧИНГИСА НАДО ЗАТИРАТЬ ДАННЫМИ ИЗ ВКЛАДЧИКА ПРИ СТАТУСАХ 6, -6, 0, 1, 3,
  IS_PAY_OSTATOK_                     P_CLAIM_PAY_OUT.IS_PAY_OSTATOK%TYPE := 0;  -- 23.10.2017  ТЕМЕКОВ АА      ЗАДАЧА 100796  , ПОЯВИЛСЯ НОВЫЙ ВЫЧИСЛЯЕМЫЙ ПАРАМЕТР
  CALL_STACK_                         VARCHAR2(1024);

  --Обязательные переменные для аудита
  Audit_Event_                        NUMBER;
--  new_val_                            types.TValue;
--  old_val_                            types.TValue;
--  DATA_OLD_TABLE                      adm.TDATA_OLD_TABLE default adm.TDATA_OLD_TABLE();

  vliErrCode                          number;
  vlsErrMsg                           varchar2(200);
  vlsIIN_Check                        varchar2(40);
  Errcode                             Adm.Types.Terr_Code := 0;
  Errmsg                              Adm.Types.Terr_Msg  := ' ';
  CNT_                                number;
  GPERSON_RECIPIENT_                  NUMBER;   -- ИДЕНТИФИКАТОР ПОЛУЧАТЕЛЯ ВЫПЛАТ (ССЫЛКА НА ТАБЛИЦУ ВКЛАДЧИКОВ, ТАК КАК РЕШИЛИ, ЧТО ЛОБОЕ ФИЗ.ЛИЦО ИМЕЮЩЕЕ ОТНОШЕНИЕ К ПЕНС.СИСТЕМЕ ПОТЕНЦИАЛЬНО МОЖЕТ ЯВЛЯТЬСЯ НАШИМ ВКЛАДЧИКОМ)
  GPERSON_TRUSTEE_                    NUMBER;   -- ИДЕНТИФИКАТОР ПОВЕРЕННОГО (ССЫЛКА НА ТАБЛИЦУ ВКЛАДЧИКОВ, ТАК КАК РЕШИЛИ, ЧТО ЛОБОЕ ФИЗ.ЛИЦО ИМЕЮЩЕЕ ОТНОШЕНИЕ К ПЕНС.СИСТЕМЕ ПОТЕНЦИАЛЬНО МОЖЕТ ЯВЛЯТЬСЯ НАШИМ ВКЛАДЧИКОМ)
  GPERSON_SETTLOR_                    NUMBER;   -- ИДЕНТИФИКАТОР ДОВЕРИТЕЛЯ  (ССЫЛКА НА ТАБЛИЦУ ВКЛАДЧИКОВ, ТАК КАК РЕШИЛИ, ЧТО ЛОБОЕ ФИЗ.ЛИЦО ИМЕЮЩЕЕ ОТНОШЕНИЕ К ПЕНС.СИСТЕМЕ ПОТЕНЦИАЛЬНО МОЖЕТ ЯВЛЯТЬСЯ НАШИМ ВКЛАДЧИКОМ)
  IS_HAVE_RIGHT_REG_OLD_LAW__         NUMBER;
  SUM_TAX_DEFERRAL_                   NUMBER;
  vlcLogs                             clob;
  vliConsentID                        number;
begin
  vlcLogs     := vlcLogs||chr(10)||(to_char(systimestamp,'hh24:mi:ss.FF')||' Start'
                        ||chr(10)||' P_CLAIM_PAY_OUT_INITIAL_['||P_CLAIM_PAY_OUT_INITIAL_||']'
                        ||chr(10)||' P_CONTRACT_['||P_CONTRACT_||']'
                        ||chr(10)||' G_PERSON_['||G_PERSON_||']'
                        ||chr(10)||' P_G_CLAIM_PAY_OUT_KND_['||P_G_CLAIM_PAY_OUT_KND_||']'
                        ||chr(10)||' P_G_PAY_OUT_SUB_TYPE_['||P_G_PAY_OUT_SUB_TYPE_||']'
                        ||chr(10)||' G_TYPE_PERIOD_['||G_TYPE_PERIOD_||']'
                        ||chr(10)||' P_G_REGISTRATION_TYPE_['||P_G_REGISTRATION_TYPE_||']'
                        ||chr(10)||' P_G_REGISTRATION_PLACE_['||P_G_REGISTRATION_PLACE_||']'
                        ||chr(10)||' IS_SEND_MAIL_['||IS_SEND_MAIL_||']'
                        ||chr(10)||' DATE_PAPER_['||DATE_PAPER_||']'
                        ||chr(10)||' DATE_RECEPTION_['||DATE_RECEPTION_||']'
                        ||chr(10)||' DATE_REGISTR_['||DATE_REGISTR_||']'
                        ||chr(10)||' HERITAGE_PERCENT_FORMAL_['||HERITAGE_PERCENT_FORMAL_||']'
                        ||chr(10)||' HERITAGE_PERCENT_REAL_['||HERITAGE_PERCENT_REAL_||']'
                        ||chr(10)||' HERITAGE_QUANTITY_['||HERITAGE_QUANTITY_||']'
                        ||chr(10)||' PRIVILEGE_IS_HAVE_['||PRIVILEGE_IS_HAVE_||']'
                        ||chr(10)||' PRIVILEGE_DATE_END_['||PRIVILEGE_DATE_END_||']'
                        ||chr(10)||' P_G_ANALYTICTYPES_['||P_G_ANALYTICTYPES_||']'
                        ||chr(10)||' P_G_ANALYTICCODES_['||P_G_ANALYTICCODES_||']'
                        ||chr(10)||' BANK_G_JUR_PERSON_['||BANK_G_JUR_PERSON_||']'
                        ||chr(10)||' G_JUR_PERSON_ACC_['||G_JUR_PERSON_ACC_||']'
                        ||chr(10)||' BANK_IS_FOREIGN_['||BANK_IS_FOREIGN_||']'
                        ||chr(10)||' BANK_BY_POST_['||BANK_BY_POST_||']'
                        ||chr(10)||' BANK_IS_CARD_ACCOUNT_['||BANK_IS_CARD_ACCOUNT_||']'
                        ||chr(10)||' BANK_BIK_['||BANK_BIK_||']'
                        ||chr(10)||' BANK_RNN_['||BANK_RNN_||']'
                        ||chr(10)||' BANK_ACCOUNT_['||BANK_ACCOUNT_||']'
                        ||chr(10)||' BANK_ACCOUNT_PERSONAL_['||BANK_ACCOUNT_PERSONAL_||']'
                        ||chr(10)||' BANK_IS_RECIPIENT_ACCOUNT_['||BANK_IS_RECIPIENT_ACCOUNT_||']'
                        ||chr(10)||' BANK_BRANCH_NAME_['||BANK_BRANCH_NAME_||']'
                        ||chr(10)||' BANK_BRANCH_CODE_['||BANK_BRANCH_CODE_||']'
                        ||chr(10)||' BANK_FOREIGN_KPP_['||BANK_FOREIGN_KPP_||']'
                        ||chr(10)||' BANK_FOREIGN_ACCOUNT_['||BANK_FOREIGN_ACCOUNT_||']'
                        ||chr(10)||' BANK_NAME_['||BANK_NAME_||']'
                        ||chr(10)||' G_CURRENCY_['||G_CURRENCY_||']'
                        ||chr(10)||' P_G_TRUSTEE_['||P_G_TRUSTEE_||']'
                        ||chr(10)||' WARRANT_NUMBER_['||WARRANT_NUMBER_||']'
                        ||chr(10)||' WARRANT_begin_DATE_['||WARRANT_begin_DATE_||']'
                        ||chr(10)||' WARRANT_END_DATE_['||WARRANT_END_DATE_||']'

                        ||chr(10)||' FM_ ['||FM_||']'
                        ||chr(10)||' NM_ ['||NM_||']'
                        ||chr(10)||' FT_ ['||FT_||']'
                        ||chr(10)||' DT_ ['||DT_||']'
                        ||chr(10)||' RNN_['||RNN_||']'
                        ||chr(10)||' IDN_['||IDN_||']'
                        ||chr(10)||' G_RESIDENTS_['||G_RESIDENTS_||']'
                        ||chr(10)||' G_COUNTRY_['||G_COUNTRY_||']'
                        ||chr(10)||' G_SEX_['||G_SEX_||']'
                        ||chr(10)||' ADDRESS_['||ADDRESS_||']'
                        ||chr(10)||' MOBPHONERASS_['||MOBPHONERASS_||']'
                        ||chr(10)||' EMAILRASS_['||EMAILRASS_||']'
                        ||chr(10)||' PHONE_['||PHONE_||']'
                        ||chr(10)||' G_ID_KIND_['||G_ID_KIND_||']'
                        ||chr(10)||' ID_SERIAL_['||ID_SERIAL_||']'
                        ||chr(10)||' ID_NUM_['||ID_NUM_||']'
                        ||chr(10)||' ID_DATE_['||ID_DATE_||']'
                        ||chr(10)||' ID_ISSUER_['||ID_ISSUER_||']'
                        ||chr(10)||' IS_INCOMPETENT_['||IS_INCOMPETENT_||']'
                        ||chr(10)||' HERITAGE_IS_PERCENT_CORRECT_['||HERITAGE_IS_PERCENT_CORRECT_||']'

                        ||chr(10)||' P_REESTR_KZ_['||P_REESTR_KZ_||']'

                        ||chr(10)||' FMTrustee_['||FMTrustee_||']'
                        ||chr(10)||' NMTrustee_['||NMTrustee_||']'
                        ||chr(10)||' FTTrustee_['||FTTrustee_||']'
                        ||chr(10)||' DTTrustee_['||DTTrustee_||']'
                        ||chr(10)||' AddressTrustee_['||AddressTrustee_||']'
                        ||chr(10)||' G_ID_KIND_Trustee_['||G_ID_KIND_Trustee_||']'
                        ||chr(10)||' ID_SERIAL_Trustee_['||ID_SERIAL_Trustee_||']'
                        ||chr(10)||' ID_NUM_Trustee_['||ID_NUM_Trustee_||']'
                        ||chr(10)||' ID_DATE_Trustee_['||ID_DATE_Trustee_||']'
                        ||chr(10)||' ID_ISSUER_Trustee_['||ID_ISSUER_Trustee_||']'
                        ||chr(10)||' RNNTrustee_['||RNNTrustee_||']'
                        ||chr(10)||' IDNTrustee_['||IDNTrustee_||']'

                        ||chr(10)||' FMSettlor_['||FMSettlor_||']'
                        ||chr(10)||' NMSettlor_['||NMSettlor_||']'
                        ||chr(10)||' FTSettlor_['||FTSettlor_||']'
                        ||chr(10)||' DTSettlor_['||DTSettlor_||']'
                        ||chr(10)||' G_ID_KIND_Settlor_['||G_ID_KIND_Settlor_||']'
                        ||chr(10)||' ID_SERIAL_Settlor_['||ID_SERIAL_Settlor_||']'
                        ||chr(10)||' ID_NUM_Settlor_['||ID_NUM_Settlor_||']'
                        ||chr(10)||' ID_DATE_Settlor_['||ID_DATE_Settlor_||']'
                        ||chr(10)||' ID_ISSUER_Settlor_['||ID_ISSUER_Settlor_||']'
                        ||chr(10)||' RNNSettlor_['||RNNSettlor_||']'
                        ||chr(10)||' IDNSettlor_['||IDNSettlor_||']'
                        ||chr(10)||' AddressSettlor_['||AddressSettlor_||']'

                        ||chr(10)||' IS_PREDSTAVITEL_['||IS_PREDSTAVITEL_||']'
                        ||chr(10)||' G_RESIDENTS_TRUSTEE_['||G_RESIDENTS_TRUSTEE_||']'
                        ||chr(10)||' G_RESIDENTS_SETTLOR_['||G_RESIDENTS_SETTLOR_||']'
                        ||chr(10)||' BANK_INTERMED_NAME_['||BANK_INTERMED_NAME_||']'
                        ||chr(10)||' BANK_INTERMED_SWIFT_['||BANK_INTERMED_SWIFT_||']'
                        ||chr(10)||' BANK_INTERMED_ACC_['||BANK_INTERMED_ACC_||']'
                        ||chr(10)||' TRUST_OSNOVANIE_['||TRUST_OSNOVANIE_||']'


                        ||chr(10)||' FMJURPREDSTAVITEL_['||FMJURPREDSTAVITEL_||']'
                        ||chr(10)||' NMJURPREDSTAVITEL_['||NMJURPREDSTAVITEL_||']'
                        ||chr(10)||' FTJURPREDSTAVITEL_['||FTJURPREDSTAVITEL_||']'
                        ||chr(10)||' IDDOCPREDSTAVITEL_['||IDDOCPREDSTAVITEL_||']'
                        ||chr(10)||' DOCNUMPREDSTAVITEL_['||DOCNUMPREDSTAVITEL_||']'
                        ||chr(10)||' DOCDATEPREDSTAVITEL_['||DOCDATEPREDSTAVITEL_||']'
                        ||chr(10)||' APPOINTPREDSTAVITEL_['||APPOINTPREDSTAVITEL_||']'


                        ||chr(10)||' CARDNUM_['||CARDNUM_||']'
                        ||chr(10)||' SORTCODE_['||SORTCODE_||']'
                        ||chr(10)||' BANK_COUNTRY_['||BANK_COUNTRY_||']'
                        ||chr(10)||' FM_LAT_['||FM_LAT_||']'
                        ||chr(10)||' NM_LAT_['||NM_LAT_||']'
                        ||chr(10)||' FT_LAT_['||FT_LAT_||']'
                        ||chr(10)||' NO_FT_['||NO_FT_||']'
                        ||chr(10)||' NO_FT2_['||NO_FT2_||']'

                        ||chr(10)||' IS_HAVE_RIGHT_REG_OLD_LAW_['||IS_HAVE_RIGHT_REG_OLD_LAW_||']'

                        ||chr(10)||' AMOUNT_['||AMOUNT_||']'
                        ||chr(10)||' AMOUNT_IS_MANUAL_['||AMOUNT_IS_MANUAL_||']'

                        ||chr(10)||' P_INGOING_PARSED_P01_['||P_INGOING_PARSED_P01_||']'
                        ||chr(10)||' IDN_CHILD_['||IDN_CHILD_||']'

                        ||chr(10)||' mode_['||mode_||']'
                        ||chr(10)||' NUMBERGK_['||NUMBERGK_||']'
                        ||chr(10)||' DATEGK_['||DATEGK_||']'
                        ||chr(10)||' G_DISTRICT_['||G_DISTRICT_||']'
                        ||chr(10)||' QUEUE_NUM_['||QUEUE_NUM_||']'
                        ||chr(10)||' DATE_PAY_RESTART_['||DATE_PAY_RESTART_||']'
                        ||chr(10)||' PHONE_PENS_['||PHONE_PENS_||']'
                        ||chr(10)||' PAYS_IS_STOPPED_GK_['||PAYS_IS_STOPPED_GK_||']'
                        ||chr(10)||' G_REASON_PAY_STOP_GK_['||G_REASON_PAY_STOP_GK_||']'
                        ||chr(10)||' REASON_PAY_STOP_GK_['||REASON_PAY_STOP_GK_||']'
                        ||chr(10)||' PAYS_IS_STOPPED_ENPF_['||PAYS_IS_STOPPED_ENPF_||']'
                        ||chr(10)||' G_REASON_PAY_STOP_ENPF_['||G_REASON_PAY_STOP_ENPF_||']'
                        ||chr(10)||' REASON_PAY_STOP_ENPF_['||REASON_PAY_STOP_ENPF_||']'
                        ||chr(10)||' G_OFFICIAL_PAY_STOPPED_['||G_OFFICIAL_PAY_STOPPED_||']'
                        ||chr(10)||' IS_HAVE_TAX_DEDUCTION_['||IS_HAVE_TAX_DEDUCTION_||']'
                        ||chr(10)||' P_INGOING_PARSED_PENS_['||P_INGOING_PARSED_PENS_||']'
                        ||chr(10)||' DATE_PAY_STOP_GK_['||DATE_PAY_STOP_GK_||']'

                        ||chr(10)||' G_PERSON_RECIPIENT_['||G_PERSON_RECIPIENT_||']'
                        ||chr(10)||' G_PERSON_TRUSTEE_['||G_PERSON_TRUSTEE_||']'
                        ||chr(10)||' G_PERSON_SETTLOR_['||G_PERSON_SETTLOR_||']'

                        ||chr(10)||' ID_DATE_END_['||ID_DATE_END_||']'
                        ||chr(10)||' ID_DATETRUSTEE_END_['||ID_DATETRUSTEE_END_||']'
                        ||chr(10)||' ID_DATESETTLOR_END_['||ID_DATESETTLOR_END_||']'
                        ||chr(10)||' P_LT_GBDFL_PERSON_DEP_['||P_LT_GBDFL_PERSON_DEP_||']'
                        ||chr(10)||' P_LT_GBDFL_PERSON_REC_['||P_LT_GBDFL_PERSON_REC_||']'
                        ||chr(10)||' P_LT_GBDFL_PERSON_TRUSTEE_['||P_LT_GBDFL_PERSON_TRUSTEE_||']'
                        ||chr(10)||' P_LT_GBDFL_PERSON_SETTLOR_['||P_LT_GBDFL_PERSON_SETTLOR_||']'

                        ||chr(10)||' PRIVILEGE_DATE_begin_['||PRIVILEGE_DATE_begin_||']'
                        ||chr(10)||' FIRST_MONTH_['||FIRST_MONTH_||']'
                        ||chr(10)||' P_G_RELATION_DEGREE_['||P_G_RELATION_DEGREE_||']'
                        ||chr(10)||' IS_HAVE_RELATION_DEGREE_['||IS_HAVE_RELATION_DEGREE_||']'
                        ||chr(10)||' g_residents_country_['||g_residents_country_||']'

                        ||chr(10)||' do_commit_['||do_commit_||']'
                        );
  if P_G_REGISTRATION_TYPE_ not in (4) then
    main.pp_Save_ERROR('P_INS_CLAIM_PAY_OUT[-4 Control] ['||nvl(Dbms_Utility.FORMAT_ERROR_BACKTRACE,'-=NULL=-') ||'] ['||DBMS_UTILITY.FORMAT_CALL_STACK||'] USERENV['||nvl(Upper(SYS_CONTEXT('USERENV','OS_USER')),'**')||'] vlcLogs['||Trim(vlcLogs)||'] ['||SUBSTR(SQLERRM,1,1000)||']');
  end if;
--- Olzhast временно сохраняю вх. параметры
-- main.pp_Save_ERROR('P_INS_CLAIM_PAY_OUT'||'] USERENV['||nvl(Upper(SYS_CONTEXT('USERENV','OS_USER')),'**')||'] vlcLogs['||Trim(vlcLogs)||']');
  Err_Code := 0;
  Err_Msg  :=' ';

  if IS_SEND_MAIL_ = 1 then
    DATE_PAPER__      := DATE_PAPER_;
    DATE_RECEPTION__  := DATE_RECEPTION_;
  end if;


  if MODE_ = 1 then          -- 02.05.2018 ТЕМЕКОВ АА ЗАДАЧА ХХ ПО ВЗАИМОДЕЙСТВИЮ С ГК, если обработка ГК, то беру даты входящие
    DATE_REGISTR__ := DATE_REGISTR_;
    DATE_PAPER__      := DATE_PAPER_;
    DATE_RECEPTION__  := DATE_RECEPTION_;
  end if;
  --- 21.06.2022 y.syunyakova Задача №615906 Реестр на выплату (от Бильданова Фарида Якубовна)
  -- При вводе заявления на Выплату по решению суда, независимо от выбранного способа подачи заявления, в связи
  -- с Выплатой по решению суда Ю.Л. (115056) поля Дата составления и Дата приема заявления сделать активными для редактирования.
   if P_G_PAY_OUT_SUB_TYPE_ in (115056,115058,115060) then
 --   DATE_REGISTR__ := DATE_REGISTR_;
    DATE_PAPER__      := DATE_PAPER_;
    DATE_RECEPTION__  := DATE_RECEPTION_;
  end if;


  CALL_STACK_ := UPPER(SUBSTR(DBMS_UTILITY.FORMAT_CALL_STACK,1,1000));      -- 26.04.2019 ТЕМЕКОВ АА, ЗАДАЧА 330091 - ЕСЛИ ЗАЯВЛЕНИЕ СОЗДАЕТСЯ ИЗ ПРОЦЕДУРЫ P_JOB_CLOSE_CONTRACT, ТО НУЖНО ИСПОЛЬЗОВАТЬ ВХОДНЫЕ ДАТЫ
  if CALL_STACK_ LIKE '%P_JOB_CLOSE_CONTRACT%' then
    DATE_REGISTR__ := DATE_REGISTR_;
    DATE_PAPER__      := DATE_PAPER_;
    DATE_RECEPTION__  := DATE_RECEPTION_;
  end if;

  GPERSON_RECIPIENT_ := TO_NUMBER(G_PERSON_RECIPIENT_);
  GPERSON_TRUSTEE_   := TO_NUMBER(G_PERSON_TRUSTEE_);
  GPERSON_SETTLOR_   := TO_NUMBER(G_PERSON_SETTLOR_);

  if MODE_ != 1 then          -- 02.05.2018 ТЕМЕКОВ АА ЗАДАЧА ХХ ПО ВЗАИМОДЕЙСТВИЮ С ГК, ЕСЛИ С ГК ТО ЭТИ ПРОВЕРКИ НЕ НУЖНЫ

    if connection_param.IsHaveLevel3 = 0 then   -- пользователь должен иметь уровень доступа 3, чтобы редактировать данные по вкладчикам и договорам
      Err_Code := -20500;
      Err_Msg  := ProcName || ' 00 ' || Adm.Error_Pack.Get_Err_Msg('0000', ErrCode, ErrMsg)|| 'Для редактирования данных по вкладчикам пользователь должен имеять уровень доступа 3. Отказано в доступе.';
      raise Types.e_Execerror;
    end if;

    if G_JUR_PERSON_ACC__ IS NOT NULL then   -- ПРОВЕРЮ СОВПАДАЕТ ЛИ СЧЕТ БАНКА ИЗ СПРАВОЧНИКА СО СЧЕТОМ КОТОРЫЙ В BANK_ACCOUNT_ ЕСЛИ НЕ СОВПАДАЮТ, ЗНАЧИТ СЧЕТ ВВЕЛИ ВРУЧНУЮ И НАДО ОБНУЛИТЬ G_JUR_PERSON_ACC__
      declare
        ACC_    G_JUR_PERSON_ACC.ACCOUNTCODE%TYPE;
      begin
        select A.ACCOUNTCODE
          into ACC_
          from G_JUR_PERSON_ACC A
         where A.G_JUR_PERSON_ACC = G_JUR_PERSON_ACC__;

        if TRIM(ACC_) <> TRIM(BANK_ACCOUNT_) then
          G_JUR_PERSON_ACC__ := NULL;
        end if;
      end;
    end if;
  end if;   -- КОНЕЦ if MODE_ != 1

  select T.P_G_PAY_OUT_TYPE, T.IS_PART
  into P_G_PAY_OUT_TYPE_, IS_PART_
  from P_G_PAY_OUT_SUB_TYPE T
  where T.P_G_PAY_OUT_SUB_TYPE = P_G_PAY_OUT_SUB_TYPE_;

  if MODE_ = 0 then
    pnt_ := '000';
    if (P_G_PAY_OUT_TYPE_ = 3 and nvl(IS_HAVE_RELATION_DEGREE_,0)=0) then

        select count(1)
          into cnt_
          from k_attached_doc# k
         where k.g_attached_doc_type in (621);
      if cnt_ = 0 then
        if IDNTrustee_ is null then

          declare
            pNum number;
            p_g_error_payments_  TYPES.TINTARRAY;
            p_claim_pay_out_voucher_ number;
          begin
            p_g_error_payments_(1) := 474;
            P_INS_CLAIM_PAY_OUT_VOUCHER(
                P_CLAIM_PAY_OUT_ => null,
                v_DATE_ => sysdate,
                NUM_ => pNum,
                OTKAZ_ => 1,
                P_CONTRACT_ => p_contract_,
                G_PERSON_ => g_person_,
                FM_ => FM_ ,--null,
                NM_ => NM_ , --null,
                FT_ => FT_,
                DT_ => DT_,
                IDN_ => IDN_,
                P_G_PAY_OUT_TYPE_ => p_g_pay_out_type_,
                POV_ZAK_PRED_ => null,
                IDN_POV_ => null,
                FM_POV_ => null,
                NM_POV_ => null,
                FT_POV_ => null,
                DT_POV_ => null,
                DOVER_OR_DOC_ => null,
                DOC_NUM_ => null,
                DOC_DATE_ => null,
                P_G_ERROR_PAYMENTS_ => p_g_error_payments_,
                NOTE_ => null,
                P_CLAIM_PAY_OUT_VOUCHER_ => p_claim_pay_out_voucher_,
                CLAIM_TYPE_  => 1, --Вид обращения 1- выплаты ПН, 2-выплаты ЦНС, 3-перевод в СО
                P_G_PAY_OUT_SUB_TYPE_ => P_G_PAY_OUT_SUB_TYPE_,
                Err_Code => ERRCODE,
                Err_Msg => ERRMSG);

             IF ERRCODE != 0 THEN
               Err_Code := -20500;
               ERR_MSG  := PROCNAME || ' ' || PNT_ || ' --> ' || ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, SQLERRM) ||
                            'Ошибка при формировании расписки об отказе';
               RAISE TYPES.E_EXECERROR;
             END IF;
             goto end_ins_claim_pay_out;

          end;

        else
          declare
            pNum number;
            p_g_error_payments_  TYPES.TINTARRAY;
            p_claim_pay_out_voucher_ number;
          begin
            p_g_error_payments_(1) := 474;
            P_INS_CLAIM_PAY_OUT_VOUCHER(
                P_CLAIM_PAY_OUT_ => null,
                v_DATE_ => sysdate,
                NUM_ => pNum,
                OTKAZ_ => 1,
                P_CONTRACT_ => p_contract_,
                G_PERSON_ => g_person_,
                FM_ => null ,
                NM_ => null ,
                FT_ => null,
                DT_ => null,
                IDN_ => null,
                P_G_PAY_OUT_TYPE_ => p_g_pay_out_type_,
                POV_ZAK_PRED_ => null,
                IDN_POV_ => IDNTrustee_,
                FM_POV_ => FMTrustee_,
                NM_POV_ => NMTrustee_,
                FT_POV_ => FTTrustee_,
                DT_POV_ => DTTrustee_,
                DOVER_OR_DOC_ => null,
                DOC_NUM_ => null,
                DOC_DATE_ => null,
                P_G_ERROR_PAYMENTS_ => p_g_error_payments_,
                NOTE_ => null,
                P_CLAIM_PAY_OUT_VOUCHER_ => p_claim_pay_out_voucher_,
                CLAIM_TYPE_  => 1, --Вид обращения 1- выплаты ПН, 2-выплаты ЦНС, 3-перевод в СО
                P_G_PAY_OUT_SUB_TYPE_ => P_G_PAY_OUT_SUB_TYPE_,
                Err_Code => ERRCODE,
                Err_Msg => ERRMSG);

             IF ERRCODE != 0 THEN
               Err_Code := -20500;
               ERR_MSG  := PROCNAME || ' ' || PNT_ || ' --> ' || ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, SQLERRM) ||
                            'Ошибка при формировании расписки об отказе';
               RAISE TYPES.E_EXECERROR;
             END IF;
             goto end_ins_claim_pay_out;
          end;
        end if;
       end if;
     end if;
  end if;

  ----------------------------------------------------------------------------------------------
  -- ЕСЛИ СОЗДАЕТСЯ ОБЫЧНОЕ ЗАЯВЛЕНИЕ НА ВЫПЛАТУ
  ----------------------------------------------------------------------------------------------
  if P_G_CLAIM_PAY_OUT_KND_ = 1 then
      -- 02.05.2018 ТЕМЕКОВ АА ЗАДАЧА ХХ ПО ВЗАИМОДЕЙСТВИЮ С ГК, ЕСЛИ С ГК ТО ЭТИ ПРОВЕРКИ НЕ НУЖНЫ
      if MODE_ != 1 then

        PNT_ := '001';
        if P_G_PAY_OUT_TYPE_ = 3 then      -- ЗАДАЧА 100796, ЕСЛИ ВЫПЛАТА НА ПОГРЕБЕНИЕ, ТО НАДО ВЫЧИСЛЯТЬ - ЭТО ОБЫЧНОЕ ПОГРЕБЕНИЕ ИЛИ ВЫПЛАТА ОСТАТКА НА ПОГРЕБЕНИЕ
          IS_PAY_OSTATOK_ := p_check_pay_claim_is_dop_vypl(null,
                                                           TO_NUMBER(g_person_),
                                                           TO_NUMBER(p_contract_),
                                                           date_reception__,
                                                           errcode,
                                                           errmsg);

          if errcode <> 0 then
            ERR_CODE := ERRCODE;
            ERR_MSG  := PROCNAME || ' ' || PNT_ || ' --> ' ||ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, ERRMSG);
            raise TYPES.E_EXECERROR;
          end if;
        end if;

        -- ЗАДАЧА 43365 - С БАУЫРЖАНОМ ПОСОВЕЩАЛИСЬ И РЕШИЛИ СОХРАНЯТЬ ВСЕГДА ССЫЛКУ НА ИСХОДНОЕ ЗАЯВЛЕНИЕ, НА БУДУЩЕЕ
        -- ТО, ЧТО СОЗДАЕТСЯ ЗАЯВЛЕНИЕ НА ИЗМЕНЕНИЕ РЕКВИЗИТОВ (НЕ ИБР) СЧИТАЕТСЯ В ЭТИХ СЛУЧАЯХ:
        -- 1) В СЛУЧАЕ, ЕСЛИ КОД ВЫПЛАТЫ ВО ВНОВЬ ПРИНИМАЕМОМ ЗАЯВЛЕНИИ СОВПАДАЕТ С ЗАКРЫВАЕМЫМ ДЕЙСТВУЮЩИМ ЗАЯВЛЕНИЕМ, НО ОТЛИЧАЕТСЯ НА ОДИН
        --    ИЛИ НЕСКОЛЬКО СЛЕДУЮЩИХ ПАРАМЕТРОВ: ДАТУ ПРИЕМА, ПЕРИОДИЧНОСТЬ («ЕЖЕГОДНАЯ», «ЕЖЕКВАРТАЛЬНАЯ», «ЕЖЕМЕСЯЧНАЯ»), ФИКСИРОВАННУЮ СУММУ;
        -- 2) В СЛУЧАЕ, ЕСЛИ КОД ВЫПЛАТЫ ВО ВНОВЬ ПРИНИМАЕМОМ ЗАЯВЛЕНИИ ОТЛИЧАЕТСЯ ОТ ЗАКРЫВАЕМОГО И ЯВЛЯЕТСЯ ОДНИМ ИЗ 408, 409, 410, 411, 508, 509, 510, 511, 901, 902, 903, 904
        -- В ЭТИХ СЛУЧАЯХ Я СОХРАНЯЮ CLAIM_NUM_, ИНАЧЕ CLAIM_NUM_ БУДЕТ ПУСТОЙ, ЗНАЧИТ ОБЫЧНОЕ ЗАЯВЛЕНИЕ
        -- 14.01.2016, ЗАДАЧА 67054 - РЕШИЛИ ОТ НОМЕРА ЗАЯВЛЕНИЙ "ИЗМ" ОТКАЗАТЬСЯ, И СТАВИТЬ ВСЕМ ПОДРЯД ОБЫЧНЫЕ НОМЕРА ЗАЯВЛЕНИЙ

        -- ЗАДАЧА 106261, ТЕМЕКОВ А.А. ПРОВЕРЯТЬ НАЛИЧИЕ ЗАКРЫТОГО ИСПОЛНЕННОГО ЗАЯВЛЕНИЯ С ТАКИМ КОДОМ, ЕСЛИ ЕСТЬ, ТО ПОЗВОЛЯТЬ ЗАВОДИТЬ
        -- В ЭТОМ СЛУЧАЕ БУДУ В КОЛОНКУ P_CLAIM_PAY_OUT_INIT_CH СТАВИТЬ -1, ЧТОБЫ ПОТОМ В ЕКЗЕШНИКЕ ЗАПУСКАТЬ НОВЫЕ ОТЧЕТЫ, А НЕ ИЗМ
        --Открыт ли вообще договор? Копылов Е

        select count(1)
        into CNT_
        from p_contract r
        where r.p_contract = P_CONTRACT_
          and r.date_close is not null;

        if CNT_ > 0 then
          Err_Code := -20500;
          Err_Msg  := adm.error_pack.GET_ERR_MSG_SHORT('0000', ProcName || ' pnt_ ' || pnt_, Err_Code, 'ВНИМАНИЕ!!! Договор закрыт подача заявления не возможна!');

          if user in ('WEB_VIPISKA', 'GK_USER') then
            Err_Msg := 'ENPF-20001';
          end if;

          raise Types.E_ExecError;
        end if;

        if P_G_PAY_OUT_TYPE_ NOT IN (3,4,5) then
          declare
            P_G_PAY_OUT_SUB_TYPE__  P_CLAIM_PAY_OUT.P_G_PAY_OUT_SUB_TYPE%TYPE;
            DATE_RECEPTION_LOCAL_   P_CLAIM_PAY_OUT.DATE_RECEPTION%TYPE;   -- ЕСЛИ МЕНЯЛАСЬ ДАТА ПРИЕМА - ЗНАЧИТ МЕНЯЛАСЬ И ПЕРИОДИЧНОСТЬ И ФИКС. СУММА, ПОЭТОМУ ЕСТЬ СМЫСЛ ПРОВЕРЯТЬ ТОЛЬКО ДАТУ ПРИЕМА
            CNT_ INTEGER;
          begin
            select P.P_CLAIM_PAY_OUT,
                   P.P_G_PAY_OUT_SUB_TYPE,
                   P.DATE_RECEPTION
                   --,P.CLAIM_NUM
            into P_CLAIM_PAY_OUT_INIT_CH_,
                 P_G_PAY_OUT_SUB_TYPE__,
                 DATE_RECEPTION_LOCAL_
                 --,CLAIM_NUM_
            from P_CLAIM_PAY_OUT P
            where P.P_CLAIM_PAY_OUT = (select MAX(P_CLAIM_PAY_OUT)
                                       from MAIN.P_CLAIM_PAY_OUT
                                       where P.G_TYPE_PERIOD <> 0
                                         and IS_ACTIVE = 1
                                         and P_CONTRACT = TO_NUMBER(P_CONTRACT_)
                                         and P_G_CLAIM_PAY_OUT_KND IN (1,2,3)
                                         and P_G_CLAIM_STATUS = 8);

          -- if (P_G_PAY_OUT_SUB_TYPE__ = P_G_PAY_OUT_SUB_TYPE_ and DATE_RECEPTION__ <> DATE_RECEPTION_LOCAL_) OR
          --             (P_G_PAY_OUT_SUB_TYPE__ <> P_G_PAY_OUT_SUB_TYPE_ and P_G_PAY_OUT_SUB_TYPE_ IN (408, 409, 410, 411, 508, 509, 510, 511, 901, 902, 903, 904)) then
          --               CLAIM_NUM_ := CLAIM_NUM_||'-ИЗМ';
          --             else
          --               CLAIM_NUM_ := NULL;
          --             end if;
          exception
            when NO_DATA_FOUND then
              -- ЗАДАЧА 106261, ТЕМЕКОВ А.А. ПРОВЕРЯТЬ НАЛИЧИЕ ЗАКРЫТОГО ИСПОЛНЕННОГО ЗАЯВЛЕНИЯ С ТАКИМ КОДОМ, ЕСЛИ ЕСТЬ, ТО ПОЗВОЛЯТЬ ЗАВОДИТЬ
              if P_G_PAY_OUT_SUB_TYPE_ IN (410, 411, 510, 511, 901, 903) then
                select COUNT(*)
                into CNT_
                from MAIN.P_CLAIM_PAY_OUT P
                where P.P_G_PAY_OUT_SUB_TYPE IN (408, 409, 410, 411, 508, 509, 510, 511, 901, 903)   -- ТЕМЕКОВ А.А. 05.08.2016, ЗАДАЧА 123907, ОКАЗЫВАЕТСЯ ПРИ ПОЛНЫХ ТОЖЕ НАДО ДАВАТЬ, ВЫЯСНИЛОСЬ В ЗАДАЧЕ 128119
                  and P.IS_ACTIVE = 0
                  and P.DATE_CLOSE IS NOT NULL
                  and P.P_G_CLAIM_STATUS = 8
                  and P.P_CONTRACT = TO_NUMBER(P_CONTRACT_)
                  and NOT EXISTS (select 1
                                  from P_CLAIM_PAY_OUT PP
                                  where PP.P_CONTRACT = TO_NUMBER(P_CONTRACT_)
                                    and PP.IS_ACTIVE = 1
                                    and PP.DATE_CLOSE IS NULL);

                if CNT_ > 0 then
                  P_CLAIM_PAY_OUT_INIT_CH_ := -1;
                else
                  P_CLAIM_PAY_OUT_INIT_CH_ := NULL;
                end if;

              else
                P_CLAIM_PAY_OUT_INIT_CH_ := NULL;
              end if;
          end;
        end if;


        pnt_ := '01';
        vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
        declare   -- ЗАЯВКА №1 ЕСЛИ СОЗДАЕТСЯ НОВОЕ ЗАЯВЛЕНИЕ, А НА ДАННЫЙ МОМЕНТ У КОНТРАКТА ЕСТЬ ЗАЯВЛЕНИЕ НА ВЫПЛАТУ С ДС ПО ГРАФИКУ, ТО ИХ АВТОМАТОМ ЗАКРЫВАТЬ
          P_CLAIM_PAY_OUT_  NUMBER := 0;
          CLOSE_RSN_        NUMBER;   -- ПРИЧИНА ЗАКРЫТИЯ, ПО ЗАДАЧЕ 43365, ЕСЛИ ЗАЯВЛЕНИЕ НА ПОГРЕБЕНИЕ СОЗДАЕТСЯ, ТО ПРИЧИНУ СТАВИТЬ 6, В ОСТАЛЬНЫХ 1
        begin
          select P_CLAIM_PAY_OUT
          into P_CLAIM_PAY_OUT_
          from P_CLAIM_PAY_OUT
          where P_CONTRACT = TO_NUMBER(P_CONTRACT_)
            and IS_ACTIVE = 1
            and P_G_CLAIM_PAY_OUT_KND = 4
            and P_G_CLAIM_STATUS = 8;

          select DECODE(PS.P_G_PAY_OUT_TYPE, 3, 6, 1)
          into CLOSE_RSN_
          from P_G_PAY_OUT_SUB_TYPE PS
          where PS.P_G_PAY_OUT_SUB_TYPE = P_G_PAY_OUT_SUB_TYPE_;

          P_CLOSE_ADDSH_PAY_OUT(P_CLAIM_PAY_OUT_,    --
                                CLOSE_RSN_,          -- 1 - ЗАКЛЮЧЕНИЕ НОВОГО ЗАЯВЛЕНИЯ НА ВЫПЛАТУ, 6 - В СВЯЗИ СО СМЕРТЬЮ ВКЛАДЧИКА
                                0,                   -- DO_COMMIT_
                                ERRCODE,
                                ERRMSG);
          vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' P_CLOSE_ADDSH_PAY_OUT P_CLAIM_PAY_OUT_['||P_CLAIM_PAY_OUT_||'] CLOSE_RSN_['||CLOSE_RSN_||'] P_G_PAY_OUT_SUB_TYPE_['||P_G_PAY_OUT_SUB_TYPE_||'] ERRCODE['||ERRCODE||'] ERRMSG['||ERRMSG||']';

          if ERRCODE <> 0 then
            ERR_CODE := ERRCODE;
            ERR_MSG  := PROCNAME || ' ' || PNT_ || ' --> ' || ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, ERRMSG);
            raise TYPES.E_EXECERROR;
          end if;
        exception
        -- 09.02.2017  ТЕМЕКОВ АА.     ЗАДАЧА 178725, ЕСЛИ ПРОИСХОДИТ ОШИБКА В P_CLOSE_ADDSH_PAY_OUT, ТО ОНА ПРОГЛАТЫВАЛАСЬ
        when TYPES.E_EXECERROR then
            raise TYPES.E_EXECERROR;
          when others then NULL;
        end;

        -- ищем № заявления
        -- ЗАДАЧА 33814, ЗАЯВКА #9315, ТЕПЕРЬ ЗАЯВЛЕНИЕ БУДЕТ ВСТАВЛЯТЬСЯ БЕЗ НОМЕРА, А НОМЕР ПРИСВАИВАТЬСЯ В САМОМ КОНЦЕ ПРОЦЕДУРЫ, МИНИМИЗИРУЯ ТЕМ САМЫМ ПРОПУСК НОМЕРОВ
        --pnt_ := '02';
        --claim_num_ := To_Char(sec_p_claim_pay_out_num.Nextval);
        -----
      end if;

      -- 19-11-2020: МАМЕТОВ СЕРИК АЛИМАМЕТОВИЧ: ПО РАБОТЕ С ИЗЪЯТИЯМИ ПН НА УЛУЧШЕНИЕ ЖИЗНЕННЫ УСЛОВИИ ПОЯВИЛОСЬ ПОНЯТИЕ ОТЛОЖЕННЫЙ ИПН. ЭТО
      -- ОЗНАЧАЕТ, ЧТО ИПН БУДЕТ УДЕРЖИВАТЬСЯ НЕ СРАЗУ НА МОМЕНТ ИЗЪЯТИЯ, А ПОЗЖЕ, ПРИ ВЫХОДЕ НА ПЕНСИЮ И ЕЩЕ В ТЕЧЕНИИ 16 ЛЕТ.
      -- РЕШЕНИЕ ПРАВИТЕЛЬСТВА СТРАНЫ КОНЕЧНО ОГОНЬ ЕПРСТ....ПОЭТОМУ ПРИ ПОСТРОЕНИИ ПЛАН ГРАФИКА ОСТАТОК НА ИПС НУЖНО ПОКАЗАТЬ ЗА МИНУСОМ СУММЫ
      -- ЗАДОЛЖЕННОСТИ ОТЛОЖЕННОГО ИПН. СУММУ ОТЛОЖЕННОГО ИПН БУДЕТ УДЕРЖИВАТЬСЯ ВСЕГДА ПЕРЕД ОСНОВНОЙ ВЫПЛАТОЙ
      pnt_ := '01a';
      vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
      -- 04-01-2021: МАМЕТОВ СЕРИК АЛИМАМЕТОВИЧ: ПОСЛЕ РАЗЪЯСНЕНИИ КГД КАСАТЕЛЬНО УЧЕТА ОТЛОЖЕННОГО ИПН ИЗМЕНИЛИСЬ РАСЧЕТЫ, ИЗМЕНИЛСЯ ПОДХОД К УЧЕТУ ОТЛОЖЕННОГО ИПН
      /*
      SUM_TAX_DEFERRAL_ := PENSION_PACK.GET_SUMM_TAX_DEFERRAL_DATE(P_CONTRACT_ => P_CONTRACT_,
                                                                   DATE_ID_ => CONNECTION_PARAM.IDOPERDAY,
                                                                   DATE_ => NULL);
      */
                          /*P_GET_SUMM_TAX_DEFERRAL(P_CONTRACT_    => P_CONTRACT_,
                                                   G_PERSON_      => NULL,
                                                   ERR_CODE       => ERRCODE,
                                                   ERR_MSG        => ERRMSG);

      if ERRCODE != 0 then
        Err_Code := -20500;
        Err_Msg  := adm.error_pack.GET_ERR_MSG_SHORT('0000', ProcName||' pnt_ '||pnt_, Err_Code,
                    'Ошибка поиска задолжености отложенного ИПН ' ||ERRMSG);
        raise Types.e_Execerror;
      end if;
      */
      ----------------------------------------------------------------------------------------------
      -- ищем сумму остатка на ИПС
      ----------------------------------------------------------------------------------------------

      if PENSION_PACK.P_GET_CONTRACT_KND(TO_NUMBER(P_CONTRACT_)) <> 20 then  --  20.02.2023  Тайканов Е.Р.  кроме анкеты-заявления
        pnt_ := '02a';
        vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
        sumremain_ := (nvl(pension_pack.GET_CONTRACT_SUMM(p_contract_), 0) + nvl(p_get_ue(p_contract_, date_reception__), 0))/* - NVL(SUM_TAX_DEFERRAL_, 0)*/;
        if nvl(sumremain_, 0) = 0 then
          Err_Code := -20500;
          Err_Msg  := adm.error_pack.GET_ERR_MSG_SHORT('0000', ProcName||' pnt_ '||pnt_, Err_Code,'Остаток на ИПС равен нулю.');
          raise Types.e_Execerror;
        end if;
        ------

        -- 15.06.2018 Темеков АА Задача 192926 надо поставить пакетную переменную, чтобы при вычислении годовой суммы вкладчику было видно что заявление создает гк
        PENSION_PACK.P_Claim_Is_Created_By_Gk := case when mode_ = 1 then 1 else 0 end;   -- Только mode_=1 ГК, остальные не ГК.

        ----------------------------------------------------------------------------------------------
        -- если заявление без Д/П (разовая выплата), то беру из Тиминой функции
        -- 10.06.2019, ТЕМЕКОВ АА ЗАДАЧА 361202, ПОСТАВИТЬ КОСТЫЛЬ ПО ДОГОВОРУ 9935285
        ----------------------------------------------------------------------------------------------
        if IS_HAVE_RIGHT_REG_OLD_LAW_ != 0 and to_number(P_CONTRACT_) <> 9935285 then
          -- для заявлений по старому законодательству, действовавшему до 01.01.2018
          if AMOUNT_IS_MANUAL_ = 0 then
            pnt_ := '02b';
            vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
            declare
              is_vip_ number;  -- чисто для процедуры
              min_pens_ number;
            begin
              amount__ := pension_pack.p_get_recipient_summ_year(to_number(P_CONTRACT_),
                                                                 DATE_RECEPTION__,
                                                                 sumremain_,
                                                                 is_vip_,
                                                                 Errcode,
                                                                 Errmsg);

              PENSION_PACK.P_Claim_Is_Created_By_Gk := NULL;    -- ВОЗВРАЩАЮ ПАКЕТНУЮ ПЕРЕМЕННУЮ В NULL ОБРАТНО 15.06.2018 Темеков АА Задача 192926

              if Errcode <> 0 or nvl(amount__, 0) = 0 then
                Err_Code := Errcode;
                Err_Msg  := ProcName || ' pnt_ '||pnt_|| ' --> ' ||Adm.Error_Pack.Get_Err_Msg('0000', Err_Code, ErrMsg)||'Ошибка вычисления максимальной годовой суммы положенной вкладчику.';
                raise Types.e_Execerror;
              end if;

              -- ЗАДАЧА №12431
              -- В ЯНВАРЕ 2015 ГОДА AMOUNT ПОЧЕМУ-ТО СТАЛ ВЫЧИСЛЯТЬСЯ С 6-Ю ЗНАКАМИ ПОСЛЕ ЗАПЯТОЙ.
              -- ИЗ-ЗА ЭТОГО, ЧТОБЫ НЕ ПЕРЕДЕЛЫВАТЬ ПЕНСИОН_ПАК, РЕШИЛИ ПРОСТО ПОСТАВИТЬ ОКРУГЛЕНИЕ ЗДЕСЬ.
              amount__ := round(amount__, 2);

              -- эту проверку сказали поставить ТИМУР И СЕРИК, 10,10,2013 ТОЛЬКО ДЛЯ РАЗОВОЙ ВЫПЛАТЫ
              if G_TYPE_PERIOD_ = 0 then
                min_pens_ := pension_pack.GET_MIN_PENSION_SUMM(DATE_RECEPTION__,
                                                               Errcode,
                                                               Errmsg);
                if Errcode <> 0 or nvl(min_pens_, 0) = 0 then
                  Err_Code := Errcode;
                  Err_Msg  := ProcName || ' pnt_ '||pnt_|| ' --> ' ||Adm.Error_Pack.Get_Err_Msg('0000', Err_Code, ErrMsg)||'Ошибка вычисления минимальной пенсии.';
                  raise Types.e_Execerror;
                end if;

                if sumremain_ - amount__ < min_pens_ then
                  amount__ := sumremain_;
                end if;
              end if;
            end;
          else
              amount__ := amount_;
          end if;
          ------
        else
          -- 07.12.2017  Сарсенбаев, Омирбаев ЗАДАЧА 98809, для заявлений по новому законодательству, действующему с 01.01.2018
          pnt_ := '02c';
          vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
          declare
            MIN_LIVING_LEVEL_ number;
          begin
            PENSION_PACK.P_G_Pay_Out_Type := P_G_PAY_OUT_TYPE_;    -- 17.07.2018 Темеков АА ставлю для Бауыржана пакетную переменную с типом выплаты

            amount__ := p_get_recipient_summ_year_real (P_CONTRACT_ => to_number(P_CONTRACT_),
                                                    DATE_ => DATE_RECEPTION__,
                                                    P_CLAIM_PAY_OUT_ => null,
                                                    ERR_CODE => ERRCODE,
                                                    ERR_MSG => ERRMSG);

            PENSION_PACK.P_Claim_Is_Created_By_Gk := NULL;    -- ВОЗВРАЩАЮ ПАКЕТНУЮ ПЕРЕМЕННУЮ В NULL ОБРАТНО 15.06.2018 Темеков АА Задача 192926
            PENSION_PACK.P_G_Pay_Out_Type := NULL;            -- ВОЗВРАЩАЮ ПАКЕТНУЮ ПЕРЕМЕННУЮ В NULL ОБРАТНО 17.07.2018 Темеков АА

            if Errcode <> 0 or nvl(amount__, 0) = 0 then
              Err_Code := Errcode;
              Err_Msg  := ProcName || ' pnt_ '||pnt_|| ' --> ' ||Adm.Error_Pack.Get_Err_Msg('0000', Err_Code, ErrMsg)||'Ошибка вычисления максимальной годовой суммы положенной вкладчику.';
              raise Types.e_Execerror;
            end if;

            -- ЗАДАЧА №12431
            -- В ЯНВАРЕ 2015 ГОДА AMOUNT ПОЧЕМУ-ТО СТАЛ ВЫЧИСЛЯТЬСЯ С 6-Ю ЗНАКАМИ ПОСЛЕ ЗАПЯТОЙ.
            -- ИЗ-ЗА ЭТОГО, ЧТОБЫ НЕ ПЕРЕДЕЛЫВАТЬ ПЕНСИОН_ПАК, РЕШИЛИ ПРОСТО ПОСТАВИТЬ ОКРУГЛЕНИЕ ЗДЕСЬ.
            amount__ := round(amount__, 2);


            if G_TYPE_PERIOD_ = 0 then       -- 10.10.2013  ТИМУР И СЕРИК   эту проверку сказали поставить ,  ТОЛЬКО ДЛЯ РАЗОВОЙ ВЫПЛАТЫ
                MIN_LIVING_LEVEL_ := ROUND(GET_MIN_LIVING_LEVEL(DATE_RECEPTION__) * 0.54,2);
                if Errcode <> 0 or nvl(MIN_LIVING_LEVEL_, 0) = 0 then
                  Err_Code := Errcode;
                  Err_Msg  := ProcName || ' pnt_ '||pnt_|| ' --> ' ||Adm.Error_Pack.Get_Err_Msg('0000', Err_Code, ErrMsg)||
                              'Ошибка вычисления 54% прожиточного минимума.';
                  raise Types.e_Execerror;
                end if;

                if sumremain_ - amount__ < MIN_LIVING_LEVEL_ then
                  amount__ := sumremain_;
                end if;
            end if;
          end;
          ------
        end if;
      end if;  --- if PENSION_PACK.P_GET_CONTRACT_KND(TO_NUMBER(P_CONTRACT_)) <> 20 then

      PENSION_PACK.P_Claim_Is_Created_By_Gk := NULL;    -- ВДРУГ ТАМ НЕ ПОПАЛО НИ В ОДНУ ВЕТКУ, ВОЗВРАЩАЮ ПАКЕТНУЮ ПЕРЕМЕННУЮ В NULL ОБРАТНО 15.06.2018 Темеков АА Задача 192926

      pnt_ := '03';
      vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
      --- OlzhasT 24.02.2025 Вставил доп проверку из-за путаницы в интерфейсе, неверно сажает переменную IS_HAVE_RIGHT_REG_OLD_LAW_
      -- пока ограничил только заявлениями ЕАЭС из-за постоянных жалоб
  if IS_HAVE_RIGHT_REG_OLD_LAW_<>0 and P_G_PAY_OUT_SUB_TYPE_ in (10000,10001,10002,10003,10004,10005,10006,10007) then
    IS_HAVE_RIGHT_REG_OLD_LAW__ :=0; --- по идее по всем новым заявлениям должен быть 0
  ELSE
    select DECODE(IS_HAVE_RIGHT_REG_OLD_LAW_, -2, -1, -3, -1, IS_HAVE_RIGHT_REG_OLD_LAW_)
       into IS_HAVE_RIGHT_REG_OLD_LAW__
        from DUAL;
  end if;

      begin
        P_INSERT_CLAIM_PAY_OUT(NULL,                     -- REFERENCE_,
                               P_G_CLAIM_PAY_OUT_KND_,
                               TO_NUMBER(P_CONTRACT_),
                               P_G_PAY_OUT_SUB_TYPE_,
                               -6,                        -- P_G_CLAIM_STATUS_ =  НЕОТРАБОТАННЫЕ В РП/АП
                               G_TYPE_PERIOD_,
                               P_G_REGISTRATION_TYPE_,
                               P_G_REGISTRATION_PLACE_,
                               CLAIM_NUM_,
                               IS_SEND_MAIL_,
                               DATE_PAPER__,
                               DATE_RECEPTION__,
                               DATE_REGISTR__,
                               HERITAGE_PERCENT_FORMAL_,
                               HERITAGE_PERCENT_REAL_,
                               HERITAGE_QUANTITY_,
                               PRIVILEGE_IS_HAVE_,
                               PRIVILEGE_DATE_END_,
                               P_G_ANALYTICTYPES_,
                               P_G_ANALYTICCODES_,
                               BANK_G_JUR_PERSON_,
                               G_JUR_PERSON_ACC__,
                               BANK_IS_FOREIGN_,
                               BANK_BY_POST_,
                               BANK_IS_CARD_ACCOUNT_,
                               BANK_BIK_,
                               BANK_RNN_,
                               BANK_ACCOUNT_,
                               BANK_ACCOUNT_PERSONAL_,
                               BANK_IS_RECIPIENT_ACCOUNT_,
                               BANK_BRANCH_NAME_,
                               BANK_BRANCH_CODE_,
                               BANK_FOREIGN_KPP_,
                               BANK_FOREIGN_ACCOUNT_,
                               BANK_NAME_,
                               G_CURRENCY_,
                               P_G_TRUSTEE_,
                               WARRANT_NUMBER_,
                               WARRANT_begin_DATE_,
                               WARRANT_END_DATE_,
                               TRIM(FM_),
                               TRIM(NM_),
                               TRIM(FT_),
                               DT_,
                               RNN_,
                               IDN_,
                               G_RESIDENTS_,
                               G_COUNTRY_,
                               G_SEX_,
                               ADDRESS_,
                               MOBPHONERASS_,
                               EMAILRASS_,
                               PHONE_,
                               G_ID_KIND_,
                               ID_SERIAL_,
                               ID_NUM_,
                               ID_DATE_,
                               ID_ISSUER_,
                               IS_INCOMPETENT_,
                               HERITAGE_IS_PERCENT_CORRECT_,
                               CONNECTION_PARAM.IDFILIALCHILD, -- ID ФИЛИАЛА
                               NULL,                      -- P_REESTR_
                               CONNECTION_PARAM.IDUSER,
                               1,                        -- IS_LAST
                               1,                        -- IS_ACTIVE
                               SUMREMAIN_,
                               AMOUNT__,
                               AMOUNT_IS_MANUAL_,
                               -- ДАННЫЕ ПОВЕРЕННОГО
                               FMTRUSTEE_,
                               NMTRUSTEE_,
                               FTTRUSTEE_,
                               DTTRUSTEE_,
                               ADDRESSTRUSTEE_,
                               G_ID_KIND_TRUSTEE_,
                               ID_SERIAL_TRUSTEE_,
                               ID_NUM_TRUSTEE_,
                               ID_DATE_TRUSTEE_,
                               ID_ISSUER_TRUSTEE_,
                               RNNTRUSTEE_,
                               IDNTRUSTEE_,
                               --
                               -- ДАННЫЕ ДОВЕРИТЕЛЯ
                               FMSETTLOR_,
                               NMSETTLOR_,
                               FTSETTLOR_,
                               DTSETTLOR_,
                               G_ID_KIND_SETTLOR_,
                               ID_SERIAL_SETTLOR_,
                               ID_NUM_SETTLOR_,
                               ID_DATE_SETTLOR_,
                               ID_ISSUER_SETTLOR_,
                               RNNSETTLOR_,
                               IDNSETTLOR_,
                               AddressSettlor_,
                               --
                               IS_PREDSTAVITEL_,
                               G_RESIDENTS_TRUSTEE_,
                               G_RESIDENTS_SETTLOR_,
                               BANK_INTERMED_NAME_,
                               BANK_INTERMED_SWIFT_,
                               BANK_INTERMED_ACC_,
                               TRUST_OSNOVANIE_,

                               -- ПРЕДСТАВИТЕЛЬ ЮРЛИЦА
                               FMJURPREDSTAVITEL_,
                               NMJURPREDSTAVITEL_,
                               FTJURPREDSTAVITEL_,
                               IDDOCPREDSTAVITEL_,
                               DOCNUMPREDSTAVITEL_,
                               DOCDATEPREDSTAVITEL_,
                               APPOINTPREDSTAVITEL_,
                               -- НОВЫЕ ПОЛЯ ИЗ ЗАЯВКИ №2, ПУНКТ 1, ТЕМЕКОВ А.А. 19.04.2016
                               CARDNUM_,
                               SORTCODE_,
                               BANK_COUNTRY_,
                               FM_LAT_,
                               NM_LAT_,
                               FT_LAT_,
                               NO_FT_,
                               NO_FT2_,
                               --
                               IS_PAY_OSTATOK_,
                               IS_HAVE_RIGHT_REG_OLD_LAW__,  -- ЗАДАЧА 98809, 27.11.2017 ТЕМЕКОВ АА.
                               --
                               NUMBERGK_,
                               DATEGK_,
                               G_DISTRICT_,
                               QUEUE_NUM_,
                               DATE_PAY_RESTART_,
                               PHONE_PENS_,
                               PAYS_IS_STOPPED_GK_,
                               G_REASON_PAY_STOP_GK_,
                               REASON_PAY_STOP_GK_,
                               PAYS_IS_STOPPED_ENPF_,
                               G_REASON_PAY_STOP_ENPF_,
                               REASON_PAY_STOP_ENPF_,
                               G_OFFICIAL_PAY_STOPPED_,
                               IS_HAVE_TAX_DEDUCTION_,
                               P_INGOING_PARSED_PENS_,
                               DATE_PAY_STOP_GK_,
                               GPERSON_RECIPIENT_,
                               GPERSON_TRUSTEE_,
                               GPERSON_SETTLOR_,
                               ID_DATE_END_,
                               ID_DATETRUSTEE_END_,
                               ID_DATESETTLOR_END_,
                               --
                               PRIVILEGE_DATE_begin_,
                               FIRST_MONTH_,
                               P_G_RELATION_DEGREE_,
                               IS_HAVE_RELATION_DEGREE_,
                               g_residents_country_,
                               P_CLAIM_PAY_OUT__,
                               ERRCODE,
                               ERRMSG);
        if ERRCODE <> 0 then
          ERR_CODE := ERRCODE;
          ERR_MSG  := PROCNAME || ' ' || PNT_ || ' --> ' || ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, ERRMSG);
          raise TYPES.E_EXECERROR;
        else
          -- 08.06.2018 TemekovAA отключил проверку, если создание заявления через ГК
          if mode_ != 1 then
            -- 05.05.2018  AnvarT          Добавлена проверка на валидность ИБАН, запрос идет через вебсервис в случае ошибки записывается в p_claim_po_comment
            -- 25.05.2018  AnvarT          Добавлена проверка на валидность ИБАН, по признаку принадлежности счета
            if BANK_IS_FOREIGN_ = 0 then   -- 29052018 Нурсултанова А. добавила проверку на ин. банк
              select decode(BANK_IS_RECIPIENT_ACCOUNT_   -- Признак принадлежности счета (2 - получателя, 1-доверителя, 0-счет поверенного) (старое поле ISDOVACCOUNT)
                                    , 0, IDNTrustee_              -- Поверенный - ИИН
                                    , 1, IDNSettlor_              -- доверитель - ИИН
                                    , 2, IDN_                     -- Получатель - ИИН
                                    )
              into vlsIIN_Check
              from dual;



              main.m__Decl.pl_Checkdeclare(
                              BANK_ACCOUNT_PERSONAL_   -- лицевой (карточный) счет получателя (старое поле  PAYPERSONALACCOUNT)
                             ,vlsIIN_Check
                             ,BANK_BIK_       -- Банк. реквизиты - БИК
                             ,BANK_IS_CARD_ACCOUNT_
                             ,vliErrCode
                             ,vlsErrMsg
                              );

              -- 27.06.2018  AidarA          ИИН подтягивается получателя, а должен поверенного, в зависимости от поля     №39690
              if  BANK_IS_RECIPIENT_ACCOUNT_ = 0 then
                insert into main.p_claim_po_comment (p_claim_po_comment,p_claim_pay_out,comments,sys_date,id_user)
                values (SEQ_P_CLAIM_PO_COMMENT.nextval,p_claim_pay_out__,'ИИН['||IDNTrustee_||'] БИК['||BANK_BIK_||'] IBAN Поверенного['||BANK_ACCOUNT_PERSONAL_||']'||vlsErrMsg,sysdate,50);
              end if;

              if  BANK_IS_RECIPIENT_ACCOUNT_ = 1 then
                insert into main.p_claim_po_comment (p_claim_po_comment,p_claim_pay_out,comments,sys_date,id_user)
                values (SEQ_P_CLAIM_PO_COMMENT.nextval,p_claim_pay_out__,'ИИН['||IDNSettlor_||'] БИК['||BANK_BIK_||'] IBAN Доверенног['||BANK_ACCOUNT_PERSONAL_||']'||vlsErrMsg,sysdate,50);
              end if;

              if  BANK_IS_RECIPIENT_ACCOUNT_ = 2 then
                insert into main.p_claim_po_comment (p_claim_po_comment,p_claim_pay_out,comments,sys_date,id_user)
                values (SEQ_P_CLAIM_PO_COMMENT.nextval,p_claim_pay_out__,'ИИН['||IDN_||'] БИК['||BANK_BIK_||'] IBAN Получателя['||BANK_ACCOUNT_PERSONAL_||']'||vlsErrMsg,sysdate,50);
              end if;
            end if;    -- if BANK_IS_FOREIGN_ = 0 then   -- 29052018 Нурсултанова А. добавила проверку на ин. банк


            -- 15.10.2020 МАМЕТОВ СЕРИК АЛИМАМЕТОВИЧ: http://enpf24.kz/company/personal/user/3215/tasks/task/view/543582/
            -- в поле "Комментарий" необходимо отображение надписи о подтверждении связи или не подтверждения связи, чтобы потом в ЭЖ работники УКОД видели эту информацию.
            if P_G_PAY_OUT_TYPE_ = 3 then
              if P_G_RELATION_DEGREE_ IS NOT NULL then
                insert into MAIN.P_CLAIM_PO_COMMENT (P_CLAIM_PO_COMMENT,P_CLAIM_PAY_OUT,COMMENTS,SYS_DATE,ID_USER)
                values (SEQ_P_CLAIM_PO_COMMENT.NEXTVAL,P_CLAIM_PAY_OUT__, DECODE(NVL(IS_HAVE_RELATION_DEGREE_, 0), 0, 'Родственная связь не подтвердилась', -1, 'Родственная связь не подтвердилась', 'Родственная связь подтвердилась'),SYSDATE, NVL(Connection_Param.idUser, 50));
              end if;

              insert into MAIN.P_CLAIM_PO_COMMENT (P_CLAIM_PO_COMMENT,P_CLAIM_PAY_OUT,COMMENTS,SYS_DATE,ID_USER)
              values (SEQ_P_CLAIM_PO_COMMENT.NEXTVAL,P_CLAIM_PAY_OUT__, DECODE(IS_HAVE_RIGHT_REG_OLD_LAW_, -2, 'Справка о смерти принята на бумажном носителе', 'Справка о смерти сформирована из ИС "ЗАГС"'),SYSDATE, NVL(Connection_Param.idUser, 50));
            end if;
            -- 15.10.2020 МАМЕТОВ СЕРИК АЛИМАМЕТОВИЧ: http://enpf24.kz/company/personal/user/3215/tasks/task/view/543582/
            -- В поле "Комментарии" передавать информацию о том на бумажном носителе представлено свидетельство о смерти
            -- или справка сформирована из ИС "ЗАГС"
            if P_G_PAY_OUT_TYPE_ = 4 and IS_HAVE_RIGHT_REG_OLD_LAW_ IN (-2, -3) then
              insert into MAIN.P_CLAIM_PO_COMMENT (P_CLAIM_PO_COMMENT,P_CLAIM_PAY_OUT,COMMENTS,SYS_DATE,ID_USER)
              values (SEQ_P_CLAIM_PO_COMMENT.NEXTVAL,P_CLAIM_PAY_OUT__, DECODE(IS_HAVE_RIGHT_REG_OLD_LAW_, -2, 'Справка о смерти принята на бумажном носителе', 'Справка о смерти сформирована из ИС "ЗАГС"'),SYSDATE, NVL(Connection_Param.idUser, 50));
            end if;
          end if;  --- if mode_ != 1 then

        end if; --- if ERRCODE <> 0  P_INSERT_CLAIM_PAY_OUT
      exception
        when Types.e_Execerror then
          raise Types.e_Execerror;
        when others then
          Err_Code := ErrCode;
          Err_Msg  := ProcName || ' pnt_ '||pnt_ ||' '|| Adm.Error_Pack.Get_Err_Msg('0000', Err_Code, ErrMsg)||'Ошибка вставки заявления';
          raise Types.e_Execerror;
          -- 05.05.2018  AnvarT          регистрация ошибки в случае свала
          main.pp_Save_ERROR('P_INS_CLAIM_PAY_OUT['||nvl(Dbms_Utility.FORMAT_ERROR_BACKTRACE,'-=NULL=-') ||'] ['||DBMS_UTILITY.FORMAT_CALL_STACK||'] USERENV['||nvl(Upper(SYS_CONTEXT('USERENV','OS_USER')),'**')||'] vlcLogs['||Trim(vlcLogs)||'] ['||SUBSTR(SQLERRM,1,1000)||']');
      end;

      -- 17.08.2016  ТЕМЕКОВ А.А.    ЗАДАЧА 130200, КОММЕНТ ЧИНГИСА ОТ , 08:59. НАДО ЗАТИРАТЬ ДАННЫМИ ИЗ ВКЛАДЧИКА ПРИ СТАТУСАХ 6, -6, 0, 1, 3,
      -- НО ПРИ ЭТОМ АПДЕЙТИТЬ ТОЛЬКО ЕСЛИ ВЫПЛАТА НЕ НАСЛЕДСТВО/ПОГРЕБЕНИЕ
      -- http://enpf24.kz/extranet/contacts/personal/log/195129/?commentId=213423#com213423
      -- http://enpf24.kz/extranet/contacts/personal/log/195129/?commentId=213774#com213774
      -- НОГИ РАСТУТ ЕЩЕ ИЗ ЗАДАЧИ 76972, ТОГДА ПОХОДУ НЕПРАВИЛЬНО ПОНЯЛ
      -- 12.06.2018 TemekovAA отключил проверку, если создание заявления через ГК
      -- 05-03-2020: МАМЕТОВ СЕРИК АЛИМАМЕТОВИЧ: ПО ЗАДАЧЕ В БИТРИКСЕ № 489217 "ЗАЯВКА №188. 'КАСАТЕЛЬНО ЗАЯВЛЕНИЯ НА ВЫПЛАТУ В ЧАСТИ ВЕРИФИКАЦИИ ДАННЫХ
      -- ВКЛАДЧИКА (ПОЛУЧАТЕЛЯ ПЕНСИОННЫХ ВЫПЛАТ)/ЗАКОННОГО ПРЕДСТАВИТЕЛЯ/ПОВЕРЕННОГО ЛИЦА С ГБД ФЛ" ДОБАВИЛ УСЛОВИЕ "- ПО ЗАЯВЛЕНИЯМ ПО ВЫЕЗДУ УБРАТЬ ОБНОВЛЕНИЕ
      -- В ЗАЯВЛЕНИИ ДАННЫХ ПОЛУЧАТЕЛЯ В АВТОМАТИЧЕСКОМ РЕЖИМЕ НА СТАТУСАХ РП (-6, 6) И ЦА (0, 1, 3) ПРИ ОБНОВЛЕНИИ КАРТОЧКИ КЛИЕНТА (ПО АНАЛОГИИ С ЗАЯВЛЕНИЯМИ ПО СМЕРТИ)"
      if MODE_ != 1 then
        if P_G_PAY_OUT_TYPE_ NOT IN (3 -- Выплата на погребение
                                    ,4 -- Выплата наследникам
                                    ,5 -- Выплата в связи с выездом на ПМЖ за пределы РК
                                    ) then
          select *
          into GPERSON_REC
          from G_NAT_PERSON G
          where G.G_PERSON = TO_NUMBER(G_PERSON_);

          update P_CLAIM_PAY_OUT P
             SET P.G_RESIDENTS = GPERSON_REC.IS_REPUBLIC_SITIZEN,
                 P.G_COUNTRY   = GPERSON_REC.G_COUNTRY,
                 P.G_ID_KIND   = GPERSON_REC.G_ID_KIND,
                 P.ID_SERIAL   = GPERSON_REC.ID_SERIAL,
                 P.ID_NUM      = GPERSON_REC.ID_NUM,
                 P.ID_DATE     = GPERSON_REC.ID_DATE,
                 P.ID_ISSUER   = GPERSON_REC.ID_ISSUER,
                 -- 27.08.2020 EKOPYLOV ПО ЗАДАЧЕ HTTP://ENPF24.KZ/WORKGROUPS/GROUP/40/TASKS/TASK/VIEW/521411/
                 -- 19.10.2020 EKOPYLOV ПО НЕ РЕЗИДЕНТАМ НЕ НАДО ПРОСТАВЛЯТЬ ЭТО ПОЛЕ, Т.К. ИХ НЕТ В НАШЕЙ БАЗЕ. ЗАДАЧА HTTP://ENPF24.KZ/WORKGROUPS/GROUP/40/TASKS/TASK/VIEW/551090/
                 P.G_PERSON_RECIPIENT = CASE when G_RESIDENTS = 1 then NVL(P.G_PERSON_RECIPIENT,GPERSON_REC.G_PERSON) end
          where P.P_CLAIM_PAY_OUT = p_claim_pay_out__;
        else    --- if P_G_PAY_OUT_TYPE_ NOT IN (3, 4, 5) then
          -- EKOPYLOV 25.09.2019 Если это заявление на погребение или наследникам, то необходимо закрыть все предыдущие заявления по графику копия кода из P_CHANGE_CLAIM_PAY_OUT_STATUS  HTTP://ENPF24.KZ/EXTRANET/CONTACTS/PERSONAL/USER/1876/TASKS/TASK/VIEW/394173/INDEX.PHP
          PNT_:='001';
          vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
          declare
            CLOSE_RSN_ NUMBER;
          begin
            for REC IN (select CP.P_CLAIM_PAY_OUT AS PAY_CLAIM_, CP.P_G_PAY_OUT_SUB_TYPE AS P_G_PAY_OUT_SUB_TYPE_
                        from MAIN.P_CLAIM_PAY_OUT CP, --(!) from MAIN.P_CLAIM_PAY_OUT$$O   CP,
                             MAIN.P_CONTRACT PC,
                             MAIN.P_G_PAY_OUT_SUB_TYPE ST
                        where CP.P_CONTRACT = PC.P_CONTRACT
                          and PC.G_PERSON_RECIPIENT = MAIN.PENSION_PACK.P_GET_CONTRACT_G_PERSON(P_CONTRACT_)
                          and CP.P_G_PAY_OUT_SUB_TYPE = ST.P_G_PAY_OUT_SUB_TYPE
                          and ST.P_G_PAY_OUT_TYPE NOT IN (3, 4, 50, 5)
                          -- and ST.P_G_PAY_OUT_TYPE IN (2,8,9,50)
                          and PC.P_CONTRACT != P_CONTRACT_
                          and CP.DATE_CLOSE IS NULL
                         ) loop

              if REC.PAY_CLAIM_ IS NOT NULL then     --  07.06.2023  AnvarT                     Чуть подравнял, и поправил закрытие
                if P_G_PAY_OUT_TYPE_ IN (3 -- Выплата на погребение
                                        ,4 -- Выплата наследникам
                                        ) then
                  CLOSE_RSN_ := 6;  -- 6 - Закрыто в связи со смертью вкладчика
                else
                  CLOSE_RSN_ := 1;  -- 1 - Заключение нового заявления на выплату
                end if;

                P_CLOSE_ADDSH_PAY_OUT(REC.PAY_CLAIM_,
                                      CLOSE_RSN_,        -- 1 - Заключение нового заявления на выплату, 6 - В связи со смертью вкладчика
                                      0,
                                      ERRCODE,
                                      ERRMSG);
                vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' P_CLOSE_ADDSH_PAY_OUT REC.PAY_CLAIM_['||REC.PAY_CLAIM_||'] CLOSE_RSN_['||CLOSE_RSN_||'] ERRCODE['||ERRCODE||'] ERRMSG['||ERRMSG||']';

                if ERRCODE <> 0 then
                  ERR_CODE := ERRCODE;
                  ERR_MSG  := PROCNAME || ' ' || PNT_ || ' --> ' || ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, ERRMSG);
                  raise TYPES.E_EXECERROR;
                end if;
              end if;  --- if REC.PAY_CLAIM_ IS NOT NULL then
            end loop; --- for REC IN
          end;
        end if;   --- if P_G_PAY_OUT_TYPE_ NOT IN (3, 4, 5) then
      end if;   --- if MODE_ != 1 then

      -- 04.05.2018 ТЕМЕКОВ АА ПРИ СОЗДАНИИ ЧЕРЕЗ ГК - РАСПИСКА О ПРИНЯТИИ ЗАЯВЛЕНИЯ НЕ НУЖНА
      if MODE_ != 1 then
        --ЗАДАЧА 43365 - СОЗДАНИЕ РАСПИСКИ О ПРИНЯТИИ ДОКУМЕНТОВ АВТОМАТОМ
        -- ТОЛЬКО ЕСЛИ ЭТО НЕ ПО ПОЧТЕ
        -- http://enpf24.kz/workgroups/group/12/tasks/task/view/54084/index.php?MID=106163#com106163
        pnt_ := '03G';
        vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
        if NVL(is_send_mail_, 0) = 0 then
          insert into P_CLAIM_PAY_OUT_VOUCHER(
            P_CLAIM_PAY_OUT_VOUCHER,
            P_CLAIM_PAY_OUT,
            P_CONTRACT,
            G_PERSON,
            P_G_PAY_OUT_TYPE,
            NUM,
            V_DATE,
            OTKAZ,
            FM_POV,
            NM_POV,
            FT_POV,
            DT_POV,
            DOC_NUM,
            DOC_DATE,
            POV_ZAK_PRED,
            DOVER_OR_DOC,
            OFFICIAL,
            SYS_DATE)
          values(
            SEQ_P_CLAIMPO_VOUCHER.NEXTVAL,
            P_CLAIM_PAY_OUT__,
            TO_NUMBER(P_CONTRACT_),
            TO_NUMBER(G_PERSON_),
            P_G_PAY_OUT_TYPE_,
            SEQ_P_CLAIMPO_VOUCHER_NUM.NEXTVAL,
            TRUNC(SYSDATE),
            0,
            FMTRUSTEE_,
            NMTRUSTEE_,
            FTTRUSTEE_,
            DTTRUSTEE_,
            WARRANT_NUMBER_,
            WARRANT_END_DATE_,
            IS_PREDSTAVITEL_,
            DECODE(TRUST_OSNOVANIE_,
                   0, 0,
                   NULL, NULL,
                   1),
            CONNECTION_PARAM.idUser,
            SYSDATE);
        end if;
      end if;

      -- ЗАДАЧА 67054, 14.01.2016 - АВТОМАТОМ СОЗДАВАТЬ ДС, ПРИ СОЗДАНИИ ЗАЯВЛЕНИЯ
      -- 13.03.2018  ТЕМЕКОВ АА  ДЕЛАТЬ ДС ПО ВСЕМ ВИДАМ ДОГОВОРОВ
      pnt_ := '03K';
      vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
      if (G_TYPE_PERIOD_ <> 0 and PENSION_PACK.P_GET_CONTRACT_KND(TO_NUMBER(P_CONTRACT_)) IN (1, 10,18, 20)) OR   -- 22.06.2018 Темеков АА Задача 192926 - надо ДС и для ТД договоров создавать
      (IS_PART_ = 1 and PENSION_PACK.P_GET_CONTRACT_KND(TO_NUMBER(P_CONTRACT_)) = 11) then
        P_INS_ADD_SHEET_PAY_OUT(P_CLAIM_PAY_OUT__,
                                4,                --P_G_CLAIM_PAY_OUT_KND_,
                                G_TYPE_PERIOD_,
                                DATE_RECEPTION__,
                                AMOUNT__,
                                AMOUNT_IS_MANUAL_,
                                1, --DO_CHECK_      -- 13.03.2018  ТЕМЕКОВ АА  ДЕЛАТЬ ДС ТЕПЕРЬ ПРОВЕРКИ
                                0, --DO_COMMIT_
                                ERRCODE,
                                ERRMSG);
        if ERRCODE <> 0 then
          ERR_CODE := ERRCODE;
          ERR_MSG  := PROCNAME || ' ' || PNT_ || ' --> ' ||
                      ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, ERRMSG);
          raise TYPES.E_EXECERROR;
        end if;
      end if;

    ----------------------------------------------------------------------------------------------
  -- ЕСЛИ СОЗДАЕТСЯ ЗАЯВЛЕНИЕ НА ИЗМЕНЕНИЕ РЕКВИЗИТОВ И УСТРАНЕНИЕ КЗ
    ----------------------------------------------------------------------------------------------
  else
      declare
          add_pay_                 number;  -- ЗАЯВЛЕНИЕ В ЦЕПИ ИСТОРИИ
          ADD_PAY_KND_             number;  -- ТИП ЗАЯВЛЕНИЯ В ЦЕПИ ИСТОРИИ
          p_g_claim_status_        p_g_claim_status.p_g_claim_status%type;
          p_g_claim_status_name_   p_g_claim_status.name%type;
          PRIVILEGE_DATE_END_OLD_  P_CLAIM_PAY_OUT.PRIVILEGE_DATE_END%type;
          NUM_                     P_CLAIM_PAY_OUT.CLAIM_NUM%TYPE;
          CNT_                     INTEGER;
      begin
          p_claim_pay_out__  := to_number(P_CLAIM_PAY_OUT_INITIAL_);

          -- заявление можно добавить только если у исходного заявления статус 8 (Исполнено в ДУиОПА)
          pnt_ := '004';
          vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
          select p.p_g_claim_status,
                 ps.name,
                 P.PRIVILEGE_DATE_END
            into p_g_claim_status_,
                 p_g_claim_status_name_,
                 PRIVILEGE_DATE_END_OLD_
            from p_claim_pay_out p,
                 p_g_claim_status ps
           where p.p_claim_pay_out = p.p_claim_pay_out
             and ps.p_g_claim_status = p.p_g_claim_status
             and p.p_claim_pay_out = p_claim_pay_out__;

          if p_g_claim_status_ != 8 and p_g_claim_status_ not in (-3, -7) then
            err_code :=  -20500;
            err_msg  := ProcName ||' pnt_ '||pnt_||' '||
                        Adm.Error_Pack.Get_Err_Msg('0000', Err_Code, ErrMsg)||
                        'Заявление можно добавить только в том случае, если исходное заявление было полностью обработано в ДУиОПА.';
            raise types.e_execerror;
          end if;

          -- block 04 --
          -- проверка - это заявление последнее в своей цепи или нет, к примеру может у него есть
          -- доп.соглашение на выплату или ИБР. если есть, то
          -- меняем IS_LAST у него, а не у текущего заявления
          pnt_ := '04';
          vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
          begin
            select p.p_claim_pay_out,
                   P.P_G_CLAIM_PAY_OUT_KND
              into add_pay_,
                   ADD_PAY_KND_
              from p_claim_pay_out p --(!) from p_claim_pay_out$$o p
             where p.p_claim_pay_out_initial = (select p_claim_pay_out_initial
                                                  from p_claim_pay_out
                                                 where p_claim_pay_out = P_CLAIM_PAY_OUT__)
               and p.is_last = 1;
          exception
            when no_data_found then
              add_pay_ := null;
            when too_many_rows then
              -- 22-02-2020: МАМЕТОВ СЕРИК АЛИМАМЕТОВИЧ: ПО ЗАМЕЧАНИЯМ АУДИТОРОВ, ЗАДАЧА В БИТРИКСЕ № 406100, БЫВАЮТ СЛУЧАЙ, КОГДА ВОЗВРАТ ВЫПЛАТ ПО ВКЛАДЧИКУ ПРИХОДИТ В ОДИН МЕСЯЦ ЗА РАЗНЫЕ ПЕРИОДЫ
              -- ТАКИМ ОБРАЗОМ У НАС ОБРАЗУЮТСЯ ДВЕ ЗАПИСИ В РЕЕСТРЕ КЗ ПО ВЫПЛАТАМ. ПРИМЕР ИИН 920120301191. ПОЛЬЗОВАТЕЛЮ В ТАКОМ СЛУЧАЕ ПРИХОДИТСЯ ДВА РАЗА ВЫЗЫВАТЬ ВКЛАДЧИКА, ЧТО ВЛЕКЕТ С
              -- СОБОЙ РЕПУТАЦИОННЫЕ РИСКИ. ЧТО БЫ ПОЛЬЗОВАТЕЛЬ В ТАКОМ СЛУЧАЕ МОГ ЗАВЕСТИ ДВА ЗАЯВЛЕНИЯ ЗА ОДИН РАЗ, НАПИСАЛ УСЛОВИЕ НИЖЕ. ТАКОЕ РЕШЕНИЕ БЫЛО ПРИНЯТО ВСЕМИ ПРИ ОБСУЖДЕНИИ В ДУИОПА
              -- ТАКЖЕ ЗА ТАКОЙ ВАРИАНТ БЫЛИ НЕ ПРОТИВ И АНАЛИТИКИ ДИТ. НО В ЦЕЛОМ ВСЕ ПОНИМАЮТ, ЧТО ЭТО НЕ САМЫЙ КРАСИВЫЙ И ВЕРНЫЙ ПУТЬ РЕШЕНИЯ ПРОБЛЕМЫ, НО ОН САМЫЙ БЫСТРЫЙ.
              for rec in (select p.p_claim_pay_out as add_pay_,
                                 P.P_G_CLAIM_PAY_OUT_KND as ADD_PAY_KND_
                            from p_claim_pay_out p --(!) from p_claim_pay_out$$o p
                           where p.p_claim_pay_out_initial = (select p_claim_pay_out_initial
                                                                from p_claim_pay_out
                                                               where p_claim_pay_out = P_CLAIM_PAY_OUT__)
                             and p.is_last = 1)
              loop
                update p_claim_pay_out p
                   set p.is_last = 0
                 where p.p_claim_pay_out = decode(rec.add_pay_, null, P_CLAIM_PAY_OUT__, rec.add_pay_);

                -- ЕСЛИ ИБР, ТО СТАВЛЮ IS_ACTIVE = 0, НО ДЕЛАЮ ЭТО ТАК:
                -- ЕСЛИ ПОСЛЕДНЕЕ В ЦЕПИ - ДС, ТО ОБНОВЛЯЮ ИСХОДНОМУ ЗАЯВЛЕНИЮ,
                -- ЕСЛИ ЖЕ ЧТО-ТО ДРУГОЕ, ТО ОБНОВЛЯЮ ЭТОМУ "ЧТО-ТО ДРУГОМУ"
                if P_G_CLAIM_PAY_OUT_KND_ = 2 then
                  update p_claim_pay_out p
                     set p.is_active = 0
                   where p.p_claim_pay_out = decode(rec.ADD_PAY_KND_, 4, P_CLAIM_PAY_OUT__, rec.add_pay_);
                end if;
              end loop;
            when others then
              Err_Code := Errcode;
              Err_Msg  := ProcName ||' pnt_ '||pnt_||' '||
                          Adm.Error_Pack.Get_Err_Msg('0000', Err_Code, ErrMsg)||
                          'Ошибка при поиске истории по данному заявлению';
              raise Types.e_Execerror;
          end;

          update p_claim_pay_out p
             set p.is_last = 0
           where p.p_claim_pay_out = decode(add_pay_, null, P_CLAIM_PAY_OUT__, add_pay_);

          -- ЕСЛИ ИБР, ТО СТАВЛЮ IS_ACTIVE = 0, НО ДЕЛАЮ ЭТО ТАК:
          -- ЕСЛИ ПОСЛЕДНЕЕ В ЦЕПИ - ДС, ТО ОБНОВЛЯЮ ИСХОДНОМУ ЗАЯВЛЕНИЮ,
          -- ЕСЛИ ЖЕ ЧТО-ТО ДРУГОЕ, ТО ОБНОВЛЯЮ ЭТОМУ "ЧТО-ТО ДРУГОМУ"
          if P_G_CLAIM_PAY_OUT_KND_ = 2 then
            update p_claim_pay_out p
               set p.is_active = 0
             where p.p_claim_pay_out = decode(ADD_PAY_KND_, 4, P_CLAIM_PAY_OUT__, add_pay_);
          end if;
          -- block 04 end --

          -- block 05 --
          -- создаем копию записи заявления, ставим ей признаки IS_ACTIVE, IS_LAST в 1
          pnt_ := '05';
          vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
          p_insert_claim_pay_out_his(p_claim_pay_out__,
                                     errcode,
                                     errmsg);
          if Errcode <> 0 then
            Err_Code := Errcode;
            Err_Msg  := ProcName || ' ' || pnt_ || ' --> ' ||
                        Adm.Error_Pack.Get_Err_Msg('0000', Err_Code, ErrMsg);
            raise Types.e_Execerror;
          end if;

          -- 17.08.2016  ТЕМЕКОВ А.А.    ЗАДАЧА 130200 КОММЕНТ ЧИНГИСА НАДО ЗАТИРАТЬ ДАННЫМИ ИЗ ВКЛАДЧИКА ПРИ СТАТУСАХ 6, -6, 0, 1, 3,
          -- НО ПРИ ЭТОМ АПДЕЙТИТЬ ТОЛЬКО ЕСЛИ ВЫПЛАТА НЕ НАСЛЕДСТВО/ПОГРЕБЕНИЕ
          -- http://enpf24.kz/extranet/contacts/personal/log/195129/?commentId=213423#com213423
          -- http://enpf24.kz/extranet/contacts/personal/log/195129/?commentId=213774#com213774
          -- НОГИ РАСТУТ ЕЩЕ ИЗ ЗАДАЧИ 76972, ТОГДА ПОХОДУ НЕПРАВИЛЬНО ПОНЯЛ
          -- 05-03-2020: МАМЕТОВ СЕРИК АЛИМАМЕТОВИЧ: ПО ЗАДАЧЕ В БИТРИКСЕ № 489217 "ЗАЯВКА №188. 'КАСАТЕЛЬНО ЗАЯВЛЕНИЯ НА ВЫПЛАТУ В ЧАСТИ ВЕРИФИКАЦИИ ДАННЫХ
          -- ВКЛАДЧИКА (ПОЛУЧАТЕЛЯ ПЕНСИОННЫХ ВЫПЛАТ)/ЗАКОННОГО ПРЕДСТАВИТЕЛЯ/ПОВЕРЕННОГО ЛИЦА С ГБД ФЛ" ДОБАВИЛ УСЛОВИЕ "- ПО ЗАЯВЛЕНИЯМ ПО ВЫЕЗДУ УБРАТЬ ОБНОВЛЕНИЕ
          -- В ЗАЯВЛЕНИИ ДАННЫХ ПОЛУЧАТЕЛЯ В АВТОМАТИЧЕСКОМ РЕЖИМЕ НА СТАТУСАХ РП (-6, 6) И ЦА (0, 1, 3) ПРИ ОБНОВЛЕНИИ КАРТОЧКИ КЛИЕНТА (ПО АНАЛОГИИ С ЗАЯВЛЕНИЯМИ ПО СМЕРТИ)"
          -- 15.08.2024 OlzhasT добавил в исключение Анкету заявление
          if P_G_PAY_OUT_TYPE_ NOT IN (3, 4, 5, 51) then
            select *
              into GPERSON_REC
              from G_NAT_PERSON G
             where G.G_PERSON = TO_NUMBER(G_PERSON_);
          end if;

          -- 16.11.2017  ТЕМЕКОВ АЙДЫН   ЗАДАЧА 97514, номер надо искать если это КЗ
          pnt_ := '05a';
          vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
          if P_G_CLAIM_PAY_OUT_KND_ = 3 then
            if p_get_is_transfered_ips(P_REESTR_KZ_) = 0 then
              -- если это разовая выплата, то просто -КЗ, если же по графику, то надо искать пропущенные выплаты по графику
              if G_TYPE_PERIOD_ <> 0 then
                select count(*)
                  into cnt_
                  from p_grfrct h,
                       p_grf f
                 where h.p_claim_pay_out = P_CLAIM_PAY_OUT_INITIAL_
                   and h.p_grfrct = f.p_grfrct
                   and f.is_payed = 0
                   and f.date_pay < connection_param.dOper;
                if cnt_ > 0 then
                  NUM_ := '-КЗ-ДВ';
                else
                  NUM_ := '-КЗ';
                end if;
              else
                NUM_ := '-КЗ';
              end if;
            else
              NUM_ := '-КЗ-ИПС';
            end if;
          ELSif P_G_CLAIM_PAY_OUT_KND_ = 2 then
            NUM_ := '-ИБР';
          end if;

          pnt_ := '05b';
          vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
          update p_claim_pay_out p
             set p.P_G_PAY_OUT_SUB_TYPE  = P_G_PAY_OUT_SUB_TYPE_,  -- 21.12.2017 ТемековА, Задача 98809, теперь в КЗ можно менять вид выплаты - льгота/нельгота
                 p.p_g_claim_pay_out_knd = p_g_claim_pay_out_knd_,
                 p.claim_num             = p.CLAIM_NUM ||NUM_,
                 p.date_paper            = DATE_PAPER__,
                 p.date_reception        = DATE_RECEPTION__,
                 p.date_registr          = DATE_REGISTR__,
                 P.P_G_REGISTRATION_TYPE = P_G_REGISTRATION_TYPE_,  --25.01.2016, ТЕМЕКОВ А.А. №69199
                 p.fm                    = trim(fm_),
                 p.nm                    = trim(nm_),
                 p.ft                    = trim(ft_),
                 p.dt                    = dt_,
                 p.rnn                   = rnn_,
                 p.idn                   = idn_,
                 p.phone                 = phone_,
                 p.MOBPHONERASS          = MOBPHONERASS_,
                 P.EMAILRASS             = EMAILRASS_,
                 p.is_incompetent        = is_incompetent_,
                 p.g_id_kind             = CASE when P_G_PAY_OUT_TYPE_ IN (3,4,5,51) then g_id_kind_ else  GPERSON_REC.G_ID_KIND end,        -- НАЧАЛО ЗАДАЧА 130200 ТЕМЕКОВ А.А., КОММЕНТ ЧИНГИСА ОТ 17.08.2016, 08:59
                 p.id_serial             = CASE when P_G_PAY_OUT_TYPE_ IN (3,4,5,51) then id_serial_ else  GPERSON_REC.ID_SERIAL end,
                 p.id_num                = CASE when P_G_PAY_OUT_TYPE_ IN (3,4,5,51) then id_num_ else  GPERSON_REC.ID_NUM end,
                 p.id_date               = CASE when P_G_PAY_OUT_TYPE_ IN (3,4,5,51) then id_date_ else  GPERSON_REC.ID_DATE end,
                 P.ID_DATE_END           = Nvl(ID_DATE_END_, GPERSON_REC.ID_DATE_END),
                 P.G_PERSON_RECIPIENT    = CASE when P_G_PAY_OUT_TYPE_ IN (3,4,5,51) then GPERSON_RECIPIENT_ else  GPERSON_REC.G_PERSON end,
                 p.id_issuer             = CASE when P_G_PAY_OUT_TYPE_ IN (3,4,5,51) then id_issuer_ else  GPERSON_REC.ID_ISSUER end,
                 P.G_RESIDENTS           = CASE when P_G_PAY_OUT_TYPE_ IN (3,4,5,51) then P.G_RESIDENTS else  GPERSON_REC.IS_REPUBLIC_SITIZEN end,
                 P.G_COUNTRY             = CASE when P_G_PAY_OUT_TYPE_ IN (3,4,5,51) then P.G_COUNTRY else  GPERSON_REC.G_COUNTRY end,       -- КОНЕЦ ЗАДАЧА 130200 ТЕМЕКОВ А.А., КОММЕНТ ЧИНГИСА ОТ 17.08.2016, 08:59
                 p.address               = address_,
                 p.bank_g_jur_person     = BANK_G_JUR_PERSON_,
                 p.G_JUR_PERSON_ACC      = G_JUR_PERSON_ACC_,
                 p.BANK_IS_FOREIGN       = BANK_IS_FOREIGN_,
                 p.BANK_BY_POST          = BANK_BY_POST_,
                 p.BANK_IS_CARD_ACCOUNT  = BANK_IS_CARD_ACCOUNT_,
                 p.BANK_BIK              = BANK_BIK_,
                 p.BANK_RNN              = BANK_RNN_,
                 p.BANK_ACCOUNT          = BANK_ACCOUNT_,
                 p.BANK_ACCOUNT_PERSONAL = BANK_ACCOUNT_PERSONAL_,
                 p.BANK_IS_RECIPIENT_ACCOUNT  = BANK_IS_RECIPIENT_ACCOUNT_,
                 p.BANK_BRANCH_NAME           = BANK_BRANCH_NAME_,
                 p.BANK_FOREIGN_KPP           = BANK_FOREIGN_KPP_,
                 p.BANK_FOREIGN_ACCOUNT       = BANK_FOREIGN_ACCOUNT_,
                 p.BANK_NAME                  = BANK_NAME_,
                 p.g_currency                 = G_CURRENCY_,
                 p.p_g_trustee                = p_g_trustee_,
                 p.warrant_number             = WARRANT_NUMBER_,
                 p.warrant_begin_date         = WARRANT_begin_DATE_,
                 p.warrant_end_date           = WARRANT_END_DATE_,
                 p.id_usr                     = connection_param.idUser,
                 p.g_filial                   = connection_param.idFilialChild,
                 p.sys_date                   = SYSDATE,
                 p.date_close                 = null,
                 p.p_g_claim_status           = -6, -- (необработанные РП)
                 p.is_active                  = 1,
                 p.is_last                    = 1,
                 p.ext_is_confirm_frontoffice     = 0,
                 p.ext_is_confirm_frontoffice_usr = null,
                 p.ext_is_confirm_fr_office_date = null,
                 p.ext_is_confirm_midloffice      = 0,
                 p.ext_is_confirm_midloffice_usr  = null,
                 p.ext_is_confirm_midloffice_date = null,
                 p.reference                      = null,
                 p.p_reestr                       = null,
                 p.p_decree                       = null,
                 --,p.g_addsh_close_reason           = null  -- Ekopylov 01.10.2015 не понятно откудо взялось, это обнуление! на боевом его нет, кто делал не понятно
                 -- БЫВАЕТ, ЧТО В ИСХОДНЫХ ЗАЯВЛЕНИЯХ ЗАПОЛНЕНЫ ПОЛЯ ДОВЕРИТЕЛЯ-ПОВЕРЕННОГО, ХОТЯ ГАЛОЧКА "ПОВЕРЕННЫЙ" НЕ СТОИТ, ПОЭТОМУ НА ВСЯКИЙ ТУТ ОБНУЛЯЮ
                 -- ТЕМЕКОВ А.А. 07.10.2015 ЗАДАЧА №42285, http://enpf24.kz/extranet/contacts/personal/user/512/tasks/task/view/42285/index.php?MID=72561&IFRAME=Y#com72561
                 -- ЗАДАЧА 70843, ТЕМЕКОВ А.А. 26.01.2016. ЕСЛИ В КЗ, ИБР ГАЛОЧКА ПОВЕРЕННЫЙ МЕНЯЛАСЬ, ТО НАДО ЗАПИСЫВАТЬ НОВЫЕ РЕКВИЗИТЫ
                 P.FMTrustee = DECODE(P_G_REGISTRATION_TYPE_, 2, FMTrustee_, NULL),
                 P.NMTrustee = DECODE(P_G_REGISTRATION_TYPE_, 2, NMTrustee_, NULL),
                 P.FTTrustee = DECODE(P_G_REGISTRATION_TYPE_, 2, FTTrustee_, NULL),
                 P.DTTrustee = DECODE(P_G_REGISTRATION_TYPE_, 2, DTTrustee_, NULL),
                 P.AddressTrustee = DECODE(P_G_REGISTRATION_TYPE_, 2, AddressTrustee_, NULL),
                 P.G_ID_KINDTrustee = DECODE(P_G_REGISTRATION_TYPE_, 2, G_ID_KIND_Trustee_, NULL),
                 P.ID_SERIALTrustee = DECODE(P_G_REGISTRATION_TYPE_, 2, ID_SERIAL_Trustee_, NULL),
                 P.ID_NUMTrustee = DECODE(P_G_REGISTRATION_TYPE_, 2, ID_NUM_Trustee_, NULL),
                 P.ID_DATETrustee = DECODE(P_G_REGISTRATION_TYPE_, 2, ID_DATE_Trustee_, NULL),
                 P.ID_DATETRUSTEE_END = DECODE(P_G_REGISTRATION_TYPE_, 2, ID_DATETRUSTEE_END_, NULL),
                 P.G_PERSON_TRUSTEE = DECODE(P_G_REGISTRATION_TYPE_, 2, GPERSON_TRUSTEE_, NULL),
                 P.ID_ISSUERTrustee = DECODE(P_G_REGISTRATION_TYPE_, 2, ID_ISSUER_Trustee_, NULL),
                 P.RNNTrustee = DECODE(P_G_REGISTRATION_TYPE_, 2, RNNTrustee_, NULL),
                 P.IDNTrustee = DECODE(P_G_REGISTRATION_TYPE_, 2, IDNTrustee_, NULL),
                 P.G_RESIDENTS_TRUSTEE = DECODE(P_G_REGISTRATION_TYPE_, 2, G_RESIDENTS_TRUSTEE_, NULL),
                 P.IS_TRUSTEE_PREDSTAVITEL = DECODE(P_G_REGISTRATION_TYPE_, 2, IS_PREDSTAVITEL_, NULL),
                 --
                 p.FMSettlor = DECODE(P_G_REGISTRATION_TYPE_, 2, FMSettlor_, NULL),
                 p.NMSettlor = DECODE(P_G_REGISTRATION_TYPE_, 2, NMSettlor_, NULL),
                 p.FTSettlor = DECODE(P_G_REGISTRATION_TYPE_, 2, FTSettlor_, NULL),
                 p.DTSettlor = DECODE(P_G_REGISTRATION_TYPE_, 2, DTSettlor_, NULL),
                 p.G_ID_KINDSettlor = DECODE(P_G_REGISTRATION_TYPE_, 2, G_ID_KIND_Settlor_, NULL),
                 p.ID_SERIALSettlor = DECODE(P_G_REGISTRATION_TYPE_, 2, ID_SERIAL_Settlor_, NULL),
                 p.ID_NUMSettlor = DECODE(P_G_REGISTRATION_TYPE_, 2, ID_NUM_Settlor_, NULL),
                 p.ID_DATESettlor = DECODE(P_G_REGISTRATION_TYPE_, 2, ID_DATE_Settlor_, NULL),
                 P.ID_DATESETTLOR_END = DECODE(P_G_REGISTRATION_TYPE_, 2, ID_DATESETTLOR_END_, NULL),
                 P.G_PERSON_SETTLOR = DECODE(P_G_REGISTRATION_TYPE_, 2, GPERSON_SETTLOR_, NULL),
                 p.ID_ISSUERSettlor = DECODE(P_G_REGISTRATION_TYPE_, 2, ID_ISSUER_Settlor_, NULL),
                 p.RNNSettlor = DECODE(P_G_REGISTRATION_TYPE_, 2, RNNSettlor_, NULL),
                 p.IDNSettlor = DECODE(P_G_REGISTRATION_TYPE_, 2, IDNSettlor_, NULL),
                 p.G_RESIDENTS_SETTLOR = DECODE(P_G_REGISTRATION_TYPE_, 2, G_RESIDENTS_SETTLOR_, NULL),
                 -- новые поля из ЗАЯВКИ №2, ПУНКТ 1, ТЕМЕКОВ А.А. 19.04.2016
                 P.CARDNUM  = CARDNUM_,
                 P.SORTCODE = SORTCODE_,
                 P.BANK_COUNTRY = BANK_COUNTRY_,
                 P.FM_LAT = FM_LAT_,
                 P.NM_LAT = NM_LAT_,
                 P.FT_LAT = FT_LAT_,
                 P.PRIVILEGE_IS_HAVE = PRIVILEGE_IS_HAVE_,
                 P.PRIVILEGE_DATE_END = PRIVILEGE_DATE_END_,
                 P.P_G_ANALYTICTYPES = P_G_ANALYTICTYPES_,
                 P.P_G_ANALYTICCODES = P_G_ANALYTICCODES_,
                 P.PRIV_CORRECT_DATE = (CASE when NVL(PRIVILEGE_DATE_END_OLD_, To_Date('01.01.1900', 'DD.MM.YYYY')) <> PRIVILEGE_DATE_END_ then SYSDATE else  NULL end),    -- ЗАЯВКИ №2, ПУНКТ 2.11, ТЕМЕКОВ А.А. 19.04.2016, ЕСЛИ В КЗ/ИБР ОТЛИЧАЕТСЯ СРОК ЛЬГОТЫ ОТ ИСХОДНОГО, СДЕЛАЛ ЧЕРЕЗ CASE, ПОТОМУ ЧТО ДЕКОДЕ ОТРЕЗАЕТ ВРЕМЯ ОКАЗЦА
                 P.PRIV_CORRECT_IDUSER =  DECODE(PRIVILEGE_DATE_END_, PRIVILEGE_DATE_END_OLD_, NULL, CONNECTION_PARAM.idUser), -- ЗАЯВКИ №2, ПУНКТ 2.11, ТЕМЕКОВ А.А. 19.04.2016
                 -- 13-11-2020: Маметов Серик Алимаметович: http://enpf24.kz/workgroups/group/49/tasks/task/view/556960/
                 -- требования Гульнары Сулейменовы "Света, откройте доступ на фактич. в КЗ!!! Это даже по умолчанию должно быть, наследников никак без фактич. невозможно выплатить.
                 -- Представь, что КЗ имеется неотработанная и поступает еще взносы. ДУиОПА расчет сделает. Как по твоему проставлять в КЗ фактич.?
                 -- Тем более щас довыплаты долевикам на КЗ возвращаются. Там везде фактич. указаны."
                 P.HERITAGE_PERCENT_REAL = HERITAGE_PERCENT_REAL_,
                 P.HERITAGE_IS_PERCENT_CORRECT = HERITAGE_IS_PERCENT_CORRECT_
           where p.p_claim_pay_out = p_claim_pay_out__;

           -- 29.04.2014 ТИМА СКАЗАЛ БРАТЬ ЭТИ ДВА ПОЛЯ ИЗ ДОПИКА - AMOUNT_IS_MANUAL, GRF_KND
           declare
             --AMOUNT_IS_MANUAL_  P_CLAIM_PAY_OUT.AMOUNT_IS_MANUAL%TYPE;   13.03.2018, Т.К. ПЕРЕНЕСЕНО В ЗАЯВЛЕНИЕ, ТО НЕ НУЖНО
             GRF_KND_           P_CLAIM_PAY_OUT.GRF_KND%TYPE;
           begin
             select --P.AMOUNT_IS_MANUAL,
                    P.GRF_KND
               into --AMOUNT_IS_MANUAL_,
                    GRF_KND_
               from P_CLAIM_PAY_OUT P
              where P.P_CLAIM_PAY_OUT_INITIAL = (select P_CLAIM_PAY_OUT_INITIAL   -- СДЕЛАЛ ТАК, ПОТОМУ ЧТО ВДРУГ И ТАК-ТО УЖЕ БЫЛО ЗАЯВЛЕНИЕ ИБР, И ТОГДА ПЕРЕДАСТСЯ ЕГО ID, А НЕ P_CLAIM_PAY_OUT_INITIAL_
                                                   from P_CLAIM_PAY_OUT
                                                  where P_CLAIM_PAY_OUT = to_number(P_CLAIM_PAY_OUT_INITIAL_))
                and P.P_G_CLAIM_PAY_OUT_KND = 4;

             update P_CLAIM_PAY_OUT T
                SET --T.AMOUNT_IS_MANUAL = AMOUNT_IS_MANUAL_,
                    T.GRF_KND = GRF_KND_
              where T.P_CLAIM_PAY_OUT = p_claim_pay_out__;
           exception
             when NO_DATA_FOUND then
               NULL;  -- ЕСЛИ НЕТ ДС, ТО НИЧЕ НЕ ДЕЛАЕМ
           end;

          -- block 05 end--

          ----------------------------------------------------------------------------------------------
          -- Если заводится заявление на устранение КЗ, то обновляю поле P_CLAIM_PAY_OUT в таблице P_REESTR_KZ,
          -- и меняю данному реестру статус на 6 (Сформированно новое заявление)
          ----------------------------------------------------------------------------------------------
          pnt_ := '05b';
          vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
          begin
            if P_G_CLAIM_PAY_OUT_KND_ = 3 then
              update p_reestr_kz t
                 set t.p_claim_pay_out = p_claim_pay_out__,
                     t.p_reestr_kz_sts = 6
               where t.p_reestr_kz = to_number(p_reestr_kz_);
            end if;
          end;
      end;
  end if;

  if MODE_ != 1 then
    -- 22-01-2020: МАМЕТОВ СЕРИК АЛИМАМЕТОВИЧ: ПО ЗАДАЧЕ В БИТРИКСЕ №475259 "КАСАТЕЛЬНО ЗАЯВЛЕНИЯ НА ВЫПЛАТУ В ЧАСТИ ВЕРИФИКАЦИИ ДАННЫХ ВКЛАДЧИКА
    -- (ПОЛУЧАТЕЛЯ ПЕНСИОННЫХ ВЫПЛАТ)/ЗАКОННОГО ПРЕДСТАВИТЕЛЯ/ПОВЕРЕННОГО ЛИЦА С ГБД ФЛ" НЕОБХОДИМО ДОБАВИТЬ ЗАПИСЬ В ТАБЛИЦЕ
    -- СВЯЗИ СВЕРКИ ОБНОВЛЕННЫХ ДАННЫХ ГБДФЛ И ЗАЯВЛЕНИИ
    pnt_ := '05C';

    vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;


    if P_G_PAY_OUT_TYPE_ = 5 then  --XX.XX.2023   Тайканов Е.Р.   Если ПМЖ, то в ГБДФЛ не ходим, так что согласие сохраняем отдельно.
      M__CONSENT.P_INS_CONSENT(D__CONSENT_TYPE_ => CASE WHEN user in ('WEB_VIPISKA') THEN 3 ELSE 2 END
                              , BODY_ => null
                              , CLAIM_ID_ => P_CLAIM_PAY_OUT__
                              , CLAIM_TYPE_ => 1
                              , G_PERSON_ => nvl(G_PERSON_RECIPIENT_, G_PERSON_) -- OlzhasT 31.01.2024 Если G_PERSON_RECIPIENT_ пустой, ставим G_PERSON_
                              , DO_COMMIT_ => 0
                              , CONSENT_KIND_ => 1
                              , PERSON_TYPE_ => 1
                              , STATUS_ => 1
                              , P_CONSENT_ => vliConsentID
                              , ERR_CODE => ERRCODE
                              , ERR_MSG => ERRMSG);
    end if;

    if P_LT_GBDFL_PERSON_DEP_ IS NOT NULL then
      P_INS_LT_GBDFL_CLAIM(P_CLAIM_PAY_OUT_ => P_CLAIM_PAY_OUT__,
                           P_CLAIM_TRANSFER_ => NULL,
                           PERSON_TYPE_ => 0,
                           P_LT_GBDFL_PERSON_ => P_LT_GBDFL_PERSON_DEP_,
                           ERR_CODE => ERRCODE,
                           ERR_MSG => ERRMSG);
      if P_G_PAY_OUT_TYPE_ in (4,3) then
        M__CONSENT.P_INS_CONSENT(D__CONSENT_TYPE_ => CASE WHEN user in ('WEB_VIPISKA') THEN 3 ELSE 2 END
                                , BODY_ => null
                                , CLAIM_ID_ => P_CLAIM_PAY_OUT__
                                , CLAIM_TYPE_ => 1
                                , G_PERSON_ => TO_NUMBER(g_person_)
                                , DO_COMMIT_ => 0
                                , CONSENT_KIND_ => 1
                                , PERSON_TYPE_ => 2
                                , STATUS_ => 1
                                , P_CONSENT_ => vliConsentID
                                , ERR_CODE => ERRCODE
                                , ERR_MSG => ERRMSG);
      end if;
    end if;

    pnt_ := '05D';
    vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
    if P_LT_GBDFL_PERSON_REC_ IS NOT NULL and IDN_ IS NOT NULL /*and G_ID_KIND_ != 13*/  then
      P_INS_LT_GBDFL_CLAIM(P_CLAIM_PAY_OUT_ => P_CLAIM_PAY_OUT__,
                           P_CLAIM_TRANSFER_ => NULL,
                           PERSON_TYPE_ => 1,
                           P_LT_GBDFL_PERSON_ => P_LT_GBDFL_PERSON_REC_,
                           ERR_CODE => ERRCODE,
                           ERR_MSG => ERRMSG);
      M__CONSENT.P_INS_CONSENT(D__CONSENT_TYPE_ => CASE WHEN user in ('WEB_VIPISKA') THEN 3 ELSE 2 END
                              , BODY_ => null
                              , CLAIM_ID_ => P_CLAIM_PAY_OUT__
                              , CLAIM_TYPE_ => 1
                              , G_PERSON_ => G_PERSON_RECIPIENT_
                              , DO_COMMIT_ => 0
                              , CONSENT_KIND_ => 1
                              , STATUS_ => 1
                              , PERSON_TYPE_ => (case when P_G_PAY_OUT_TYPE_ in (2,3) then 1 else 0 end)
                              , P_CONSENT_ => vliConsentID
                              , ERR_CODE => ERRCODE
                              , ERR_MSG => ERRMSG);
    end if;

    pnt_ := '05F';
    vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
    if P_LT_GBDFL_PERSON_TRUSTEE_ IS NOT NULL and IDNTRUSTEE_ IS NOT NULL /*and G_ID_KIND_TRUSTEE_ != 13*/ then
      P_INS_LT_GBDFL_CLAIM(P_CLAIM_PAY_OUT_ => P_CLAIM_PAY_OUT__,
                           P_CLAIM_TRANSFER_ => NULL,
                           PERSON_TYPE_ => 2,
                           P_LT_GBDFL_PERSON_ => P_LT_GBDFL_PERSON_TRUSTEE_,
                           ERR_CODE => ERRCODE,
                           ERR_MSG => ERRMSG);

      M__CONSENT.P_INS_CONSENT(D__CONSENT_TYPE_ => CASE WHEN user in ('WEB_VIPISKA') THEN 3 ELSE 2 END
                              , BODY_ => null
                              , CLAIM_ID_ => P_CLAIM_PAY_OUT__
                              , CLAIM_TYPE_ => 1
                              , G_PERSON_ => G_PERSON_TRUSTEE_
                              , DO_COMMIT_ => 0
                              , CONSENT_KIND_ => 1
                              , STATUS_ => 1
                              , PERSON_TYPE_ => 2
                              , P_CONSENT_ => vliConsentID
                              , ERR_CODE => ERRCODE
                              , ERR_MSG => ERRMSG);
    end if;

    pnt_ := '05G';
    vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
    if P_LT_GBDFL_PERSON_SETTLOR_ IS NOT NULL and IDNSETTLOR_ IS NOT NULL /*and G_ID_KIND_SETTLOR_ != 13*/ then
      P_INS_LT_GBDFL_CLAIM(P_CLAIM_PAY_OUT_ => P_CLAIM_PAY_OUT__,
                           P_CLAIM_TRANSFER_ => NULL,
                           PERSON_TYPE_ => 3,
                           P_LT_GBDFL_PERSON_ => P_LT_GBDFL_PERSON_SETTLOR_,
                           ERR_CODE => ERRCODE,
                           ERR_MSG => ERRMSG);

      M__CONSENT.P_INS_CONSENT(D__CONSENT_TYPE_ => CASE WHEN user in ('WEB_VIPISKA') THEN 3 ELSE 2 END
                              , BODY_ => null
                              , CLAIM_ID_ => P_CLAIM_PAY_OUT__
                              , CLAIM_TYPE_ => 1
                              , G_PERSON_ => G_PERSON_SETTLOR_
                              , DO_COMMIT_ => 0
                              , CONSENT_KIND_ => 1
                              , STATUS_ => 1
                              , PERSON_TYPE_ => 3
                              , P_CONSENT_ => vliConsentID
                              , ERR_CODE => ERRCODE
                              , ERR_MSG => ERRMSG);

     -- P_PROCESS_GBDFL_GO(P_LT_GBDFL_PERSON_ => P_LT_GBDFL_PERSON_SETTLOR_, PERSON_TYPE_ => 3, P_G_PAY_OUT_TYPE_ => P_G_PAY_OUT_TYPE_);
    end if;

  end if;

  ----------------------------------------------------------------------------------------------
  -- вставляем запись в таблицу статусов заявления
  ----------------------------------------------------------------------------------------------
  pnt_ := '08';
  vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
  insert into p_claim_pay_out_official
    (p_claim_pay_out_official, p_claim_pay_out, official, p_g_claim_status, confirm_date)
  values
    (sec_p_claim_pay_out_official.nextval, p_claim_pay_out__, connection_param.idUser, -6, sysdate);

  ----------------------------------------------------------------------------------------------
  -- 26.03.2018 ТЕМЕКОВ АА ЗАДАЧА ХХ - НАДО СОХРАНЯТЬ ИСХОДЯЩИЙ УСПЕШНЫЙ ЗАПРОС В ГК
  -- вставляем запись в таблицу связи P_LT_CLAIM_PARSED_P01
  ----------------------------------------------------------------------------------------------
  pnt_ := '08.1';
  vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
  if P_INGOING_PARSED_P01_ IS NOT NULL then
    insert into p_lt_claim_parsed_p01
      (p_lt_claim_parsed_p01, p_claim_pay_out, p_ingoing_parsed_p01, idn)
    values
      (MAIN.SEQ_P_LT_CLAIM_PARSED_P01.NEXTVAL, P_CLAIM_PAY_OUT__, TO_NUMBER(P_INGOING_PARSED_P01_), idn_child_);
  end if;

  ----------------------------------------------------------------------------------------------
  -- update признак Резидент/Нерезидент и страну в таблице G_NAT_PERSON
  -- изменяю только если выплата не наследникам и на погребение, потому что
  -- в этом случае G_PERSON_ не совпадает
  -- А ТАКЖЕ Если данные по документу, удостоверяющиего личность, есть какие-то изменения
  -- то делаю изменения в реквизитах вкладчика, через заявление с типом "Письмо вкладчика с заявлением на перевод/выплату"
  ----------------------------------------------------------------------------------------------
  -- 11.02.2016, ТЕМЕКОВ А.А. УБИРАЮ ОЬНОВЛЕНИЕ ДАННЫХ ВКЛАДЧИКА, ЗАДАЧА 70355
  -- http://enpf24.kz/extranet/contacts/personal/user/512/tasks/task/view/70355/index.php?MID=130959&PAGEN_2=1#com130959
  /*pnt_ := '09';
  if p_g_pay_out_type_ not in (3,4) then
    update g_nat_person gn
       set gn.is_republic_sitizen = g_residents_,
           gn.g_country           = g_country_
     where gn.g_person = to_number(g_person_);

    ----------------------------------------------------------------------------------------------
    pnt_ := '11';
    begin
      p_change_id_doc_pay_claim(g_person_,
                                g_id_kind_,
                                id_serial_,
                                id_num_,
                                id_date_,
                                id_issuer_,
                                errcode,
                                errmsg);
      if Errcode <> 0 then
        Err_Code := Errcode;
        Err_Msg  := ProcName || ' ' || pnt_ || ' --> ' ||
                    Adm.Error_Pack.Get_Err_Msg('0000', Err_Code, ErrMsg);
        raise Types.e_Execerror;
      end if;
    end;
  end if; */

  ----------------------------------------------------------------------------------------------
  -- переносим из временной таблицы K_ATTACHED_DOC# в K_ATTACHED_DOC и попутно создаем запись
  -- в таблице p_claim_pay_out_attach_doc
  -- 03.09.2025 Y.Kisseleva логирование
  ----------------------------------------------------------------------------------------------
  pnt_ := '07';
  vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
  declare
    k_attached_doc_    main.k_attached_doc.k_attached_doc%type;
    vlncntLogs number;
    vlnStep    number;
  begin
    select count (*) into vlncntLogs from main.k_attached_doc# k;
    vlnStep:=0;
    for Rec in (select k.*,
                       r.g_form_attached_doc,
                       nvl(dd.is_digital_doc, 0) is_digital_doc
                  from k_attached_doc# k,
                       P_CLAIM_PAY_OUT_FORM_ATT_DOC# r,
                       P_CLAIM_PAY_OUT_ATTACH_DOC# DD --25.07.2023: Миреев А. по задаче реализации ЦД в Выплатах, добавил общение к временной таблице
                 where k.k_attached_doc = r.k_attached_doc#(+)
                   and dd.k_attached_doc(+) = k.k_attached_doc
                   )
    loop
      vlnStep:=vlnStep+1;
      -- темеков аа 02.08.2016, задача 124830, внутри происходит коммит, который мне не нужен, Серик в свое время создал
      -- переменную, и если она равна 0, то коммита нет
      PKG_AUDIT_HIS.DO_COMMIT_ATTACH_DOC_ := 0;
      k_insert_attached_doc(Rec.g_Attached_Doc_Type,
                            Rec.Attached_Doc_Object,
                            p_claim_pay_out__,
                            Rec.Doc_Date,
                            Rec.Doc_Num,
                            Rec.Note,
                            Rec.File_Name,
                            Rec.File_Ext,
                            Rec.Body,
                            rec.is_last,
                            k_attached_doc_,
                            Errcode,
                            Errmsg);
      vlcLogs     := vlcLogs||chr(10)||','||'vlnStep'||vlnStep||','||'vlncntLogs'||vlncntLogs||','||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
      
      PKG_AUDIT_HIS.DO_COMMIT_ATTACH_DOC_ := 1;    -- темеков аа 02.08.2016, задача 124830, внутри происходит коммит, который мне не нужен
      if Errcode <> 0 then   -- для теста
        Err_Code := Errcode;
        Err_Msg  := ProcName || ' ' || pnt_ || ' --> ' ||
                    Adm.Error_Pack.Get_Err_Msg('0000', Err_Code, ErrMsg);
        raise Types.e_Execerror;
      end if ;

      -- 25.07.2023: Миреев А. Задача №942206 Разработка. Модернизация ИС ИАИС-2 ПУПН. Заявка №361. 'Доработка функционала получения и хранения цифровых документов при приеме заявления на выплату/возмещение ИПН'
      -- вставку в P_CLAIM_PAY_OUT_ATTACH_DOC вынес из K_INSERT_ATTACHED_DOC сюда, для реализации ЦД в выплатах
      INSERT INTO P_CLAIM_PAY_OUT_ATTACH_DOC
        (P_CLAIM_PAY_OUT_ATTACH_DOC, P_CLAIM_PAY_OUT, K_ATTACHED_DOC, G_FORM_ATTACHED_DOC,IS_DIGITAL_DOC)
      VALUES
        (SEQ_P_CLAIM_PAY_OUT_ATTACH_DOC.NEXTVAL, P_CLAIM_PAY_OUT__, K_ATTACHED_DOC_, REC.G_FORM_ATTACHED_DOC, REC.IS_DIGITAL_DOC);

      -- надо вставлять форму документа, задача №43365
      -- ту процедуру трогать не буду, тк она много где вывызывается, поэтому буду вставлять форму документа здесь
      -- 25.07.2023: Миреев А. запонение поля G_FORM_ATTACHED_DOC перенес в верхний инсерт
      /*update p_claim_pay_out_attach_doc d
         set d.g_form_attached_doc = rec.g_form_attached_doc
       where d.k_attached_doc = k_attached_doc_;*/
    end loop;
    -- 04.04.2023 -- Тайканов Е.Р.  -- Здесь удаление убрал, так как файлы должны прикрепиться ко всем созданным заявлениям.
    --delete from k_attached_doc#;
    --delete from p_claim_pay_out_form_att_doc#;
  end;

  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- 23-10-2019: МАМЕТОВ СЕРИК АЛИМАМЕТОВИЧ: ПО ЗАДАЧЕ ДЕТЕЙ ИНВАЛИДОВ ПЕРЕНОСИМ ИЗ ВРЕМЕННОЙ ТАБЛИЦЫ P_LT_CLAIM_CHILD_INVALID# В P_LT_CLAIM_CHILD_INVALID
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  PNT_ := '08';
  vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
  declare
    G_PERSON_CHILD_   NUMBER;
  begin
    for RECINS IN (select *
                     from MAIN.P_LT_CLAIM_CHILD_INVALID#)
    loop

      P_CREATE_DEPOSITOR(FM_ => RECINS.FM,
                         NM_ => RECINS.NM,
                         FT_ => RECINS.FT,
                         DT_ => RECINS.DT,
                         IDN_ => RECINS.IDN,
                         DO_COMMIT_ => 0,
                         G_PERSON_DEPOSITOR_ => G_PERSON_CHILD_,
                         ERR_CODE => ERRCODE,
                         ERR_MSG => ERRMSG);

      begin
        insert into MAIN.P_LT_CLAIM_CHILD_INVALID(P_LT_CLAIM_CHILD_INVALID, G_PERSON, P_CLAIM_PAY_OUT, DATE_begin_PRIVILEGE,
                    DATE_END_PRIVILEGE, DOC_BASE, NUM_TRANS_ADOPTIVE_FAMILY, DATE_TRANS_ADOPTIVE_FAMILY, DATE_END_TRANS_ADOPTIVE_FAMILY, COMMENTS, SYS_DATE, ID_USER)
          values(SEQ_P_LT_CLAIM_CHILD_INVALID.NEXTVAL, G_PERSON_CHILD_, P_CLAIM_PAY_OUT__, RECINS.DATE_begin_PRIVILEGE, RECINS.DATE_END_PRIVILEGE,
                 RECINS.DOC_BASE, RECINS.NUM_TRANS_ADOPTIVE_FAMILY, RECINS.DATE_TRANS_ADOPTIVE_FAMILY, RECINS.DATE_END_TRANS_ADOPTIVE_FAMILY,
                 RECINS.COMMENTS, RECINS.SYS_DATE, RECINS.ID_USER);
      exception
        when others then
          ERR_CODE := -20500;
          ERR_MSG  := PROCNAME || ' ' || PNT_ || ' --> ' || ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, SQLERRM) ||
                      'ОШИБКА ДОБАВЛЕНИЯ ЗАПИСИ В ТАБЛИЦУ MAIN.P_LT_CLAIM_CHILD_INVALID';
          raise TYPES.E_EXECERROR;
      end;

      -- II.  ДАННЫЕ ПО РЕБЕНКУ-ИНВАЛИДУ / ОПЕКАЕМОМУ СОХРАНЯТЬ КАК ВКЛАДЧИКА БЕЗ ДОГОВОРА С ОТМЕТКОЙ
      -- "ТРЕБУЕТСЯ ПРОВЕРКА С ГБД ФЛ" ПО АНАЛОГИИ С ОТКРЫТИЕМ ПД В БЕЗЗАЯВИТЕЛЬНОМ ПОРЯДКЕ.
      begin
        insert into MAIN.P_NO_CLAIM_OPEN_CONTRACT
          (P_NO_CLAIM_OPEN_CONTRACT, P_CONTRACT, I_MT102, SYS_DATE, STATE, COMMENTS, F32A_CURR_DATE, G_PERSON)
        values
          (SEQ_P_NO_CLAIM_OPEN_CONTRACT.NEXTVAL, NULL, NULL, SYSDATE, 0, NULL, SYSDATE, G_PERSON_CHILD_);
      exception
        when others then
          ERR_CODE := -20500;
          ERR_MSG  := PROCNAME || ' ' || PNT_ || ' --> ' || ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, SQLERRM) ||
                      'ОШИБКА ДОБАВЛЕНИЯ ЗАПИСИ В ТАБЛИЦУ MAIN.P_NO_CLAIM_OPEN_CONTRACT';
          raise TYPES.E_FORCE_EXIT;
      end;
    end loop;
  end;
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  -- ЗАДАЧА 33814, ЗАЯВКА #9315, ТЕПЕРЬ ЗАЯВЛЕНИЕ БУДЕТ ВСТАВЛЯТЬСЯ БЕЗ НОМЕРА, А НОМЕР ПРИСВАИВАТЬСЯ В САМОМ КОНЦЕ ПРОЦЕДУРЫ, МИНИМИЗИРУЯ ТЕМ САМЫМ ПРОПУСК НОМЕРОВ
  if P_G_CLAIM_PAY_OUT_KND_ = 1 then
    -- ЗАДАЧА 43365 - ЕСЛИ СОЗДАЕТСЯ ЗАЯВЛЕНИЕ НА ИЗМЕНЕНИЕ РЕКВИЗИТОВ ЗАЯВЛЕНИЯ ТО К ЭТОМУ МОМЕНТУ CLAIM_NUM_ БУДЕТ УЖЕ НЕ ПУСТОЙ И ЕГО НАДО ПРИСВОИТЬ НОВОМУ ЗАЯВЛЕНИЮ
    -- 14.01.2016, ЗАДАЧА 67054 - РЕШИЛИ ОТ НОМЕРА ЗАЯВЛЕНИЙ "ИЗМ" ОТКАЗАТЬСЯ, И СТАВИТЬ ВСЕМ ПОДРЯД ОБЫЧНЫЕ НОМЕРА ЗАЯВЛЕНИЙ
    --if CLAIM_NUM_ IS NULL then
      select SEC_P_CLAIM_PAY_OUT_NUM.Nextval
        into NUM_
        from DUAL;

      CLAIM_NUM_ := To_Char(NUM_);
    --end if;

    update P_CLAIM_PAY_OUT P
       SET P.CLAIM_NUM = claim_num_,
           P.P_CLAIM_PAY_OUT_INIT_CH = P_CLAIM_PAY_OUT_INIT_CH_
     where P.P_CLAIM_PAY_OUT = P_CLAIM_PAY_OUT__;
  end if;


  -- 04.04.2023    Тайканов Е.Р.   -- Перенес ниже по коду
  --if do_commit_ = 1 then
  --  commit;
  --end if;

  ----------------------------------------------------------------------------------------------
  --ЗАЯВКА №2, ТЕМЕКОВ А.А. 27.04.2016
  ----------------------------------------------------------------------------------------------
  -- В заявлении на выплату в "Списке принятых документов" при добавлении/редактировании прикрепляемых документов «Заявление о назначении пенсионных выплат»,
  -- «Заявление на устранение КЗ», «Заявление на изменение реквизитов банковского счета» автоматически подтягивать номер и дату приема заявления в
  -- поля «Номер документа» и «Дата документа» соответственно.
  ----------------------------------------------------------------------------------------------
  begin
    update K_ATTACHED_DOC K
       SET K.DOC_NUM = CLAIM_NUM_,
           K.DOC_DATE = DATE_RECEPTION_
     where K.G_ATTACHED_DOC_TYPE IN (63, 215, 196, 361, 362, 364, 365, 381, 404, 405, 406, 435, 442, 450)    -- Чингис расширил список, 24.05.2016, Темеков, http://enpf24.kz/extranet/workgroups/group/12/tasks/task/view/102199/index.php?MID=176309&PAGEN_1=1#com176309
       and EXISTS (select 1
                     from p_claim_pay_out_attach_doc A
                    where A.K_ATTACHED_DOC = K.K_ATTACHED_DOC
                      and A.P_CLAIM_PAY_OUT = p_claim_pay_out__);
  exception
    when others then
      Err_Code := -777;
      Err_Msg := 'Внимание! Заявление сохранено успешно, но при присвоении номера и даты прикрепленным документам произошла ошибка.';
  end;

  --ЗАДАЧА 104273, ТЕМЕКОВ А.А. 02.09.2016
  P_CLAIM_PAY_OUT_ := To_Char(p_claim_pay_out__);


  --07.10.2022: Миреев А.
  --Задача Заявка №327. 'Уведом УИП при регистрации заявления на выплату'
  --При наличии у вкладчика (получателя) накоплений в УИП и поступлении в ЕНПФ заявления на выплату в связи: с погребением, наследством, решением суда, инвалидностью, ПМЖ, реализовать
  --в ИАИС-2 функционал по автоматическому формированию и отправке в УИП и ДУОПА Уведомления о передаче пенсионных активов. Уведомление о передаче пенсионных активов при поступлении в ЕНПФ
  --заявления на выплату в связи: с погребением, наследством, решением суда, инвалидностью, ПМЖ необходимо автоматически формировать и отправлять в день регистрации заявления
  --на выплату, на электронные адреса ответственных лиц УИП и ДУОПА, по аналогии с реализованным Уведомлением (СЗ № ГКОА-17113 от 06.05.2022г.), с
  --указанием предварительной суммы, в сумме находящейся в УИП на операционную дату подачи заявления и предварительной даты передачи ПА из УИП в УИП/НБРК – 2-й рабочий
  --день от даты регистрации заявления на выплату. Кроме этого, необходимо установить контроль на заявления по выплатам с наличием накоплений в УИП при заполнении таблицы: Выплаты –
  --Выплаты на текущую дату. В случае наличия ПН в УИП данные заявления выпадают в ошибочные с причиной: имеются накопления в УИП.
  pnt_ := '10A';
  vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
  declare
    WORKING_DATE_ P_OPR.WORKING_DATE%TYPE;
  begin
     CNT_:=0;
     select SUM(CN.CNT)
       into CNT_
       from (select COUNT(*) AS CNT
               from P_G_PAY_OUT_SUB_TYPE ST
              where ST.P_G_PAY_OUT_SUB_TYPE = P_G_PAY_OUT_SUB_TYPE_
                and (ST.P_G_PAY_OUT_TYPE IN (3, 4, 5, 8, 50) OR ST.P_G_PAY_OUT_SUB_TYPE IN (600, 601, 602, 603))) CN;
    if cnt_ > 0
    then
      cnt_:=0;
      --берем опер день
      select A.WORKING_DATE
        into WORKING_DATE_
        from V_CURRENT_WORKING_DATE A
       where ROWNUM = 1;
      --считаем остаток в ПН
      select nvl(SUM(ROUND(MAIN.PENSION_PACK.GET_ACCOUNT_OUTPUT_CU(MAIN.PENSION_PACK.P_GET_G_ACCOUNT_IPC(PP.P_CONTRACT, PP.P_G_PORTFOLIO),
             WORKING_DATE_,WORKING_DATE_) * MAIN.K_CURRENCY_COURSE_PACK.GET_PENSION_COURSE_REC(PP.P_G_PORTFOLIO, WORKING_DATE_),2)),0) AS summ
        into CNT_
        from P_CONTRACT PC,
             P_CONTRACT_PORTFOLIO PP
       where PC.G_PERSON_RECIPIENT = G_PERSON_
         and PC.P_CONTRACT = PP.P_CONTRACT
         AND PC.P_G_CONTRACT_KND IN (11,10,18)
         and PP.P_G_PORTFOLIO > 4;
      if cnt_ > 0 then
        --ERR_CODE := -777;
        --ErrMsgWARN  := ErrMsgWARN ||CrLf||
        --'ВНИМАНИЕ! Произведите прикрепление сканированных документов до конца рабочего дня, поскольку по данному вкладчику имеются ПН в УИП. После сохранения заявления будет  произведен возврат ПН из доверительного управления УИП в доверительное  управление НБ РК  в течение 2 рабочих дней'||CrLf;
        --'По данному вкладчику имеются ПН в УИП. После сохранения заявления будет произведен возврат ПН из доверительного управления УИП в доверительное управление НБ РК  в течение 2 рабочих дней'||CrLf;
        P_JOB_NOTIFY_UIP_BY_EMAIL(P_CLAIM_PAY_OUT_ => P_CLAIM_PAY_OUT__);
      end if;
    end if;
  exception
    when others then
      Err_Code := -777;
      Err_Msg := 'Не критическая ошибка при отправке уведомления в УИП';
  end;

  pnt_ := '10B';
  vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
  --29.03.2023: МИРЕЕВ А.
  -- 11.01.2024 Olzhast внес изменения
  --- AnvarT пока закоментил OlzhasT раскомментил, буду дорабатывать
  if P_G_PAY_OUT_TYPE_ = 51 then
    --СОХРАНЯЕМ ВЫБРАННЫЕ ВИДЫ ПЕНСИЙ ИЗ АНКЕТЫ
    select COUNT(1)
      into CNT_
      from MAIN.P_CLAIM_PAY_OUT_EAES_ANKETA# EA;
    if CNT_= 1 then
      --ГРОХАЕМ ВСЕ ВСЕ ПО ВЫБРАННОМУ ЗАЯВЛЕНИЮ
      DELETE from MAIN.P_CLAIM_PAY_OUT_EAES_ANKETA EA where EA.P_CLAIM_PAY_OUT = P_CLAIM_PAY_OUT__;
      DELETE from MAIN.P_CLAIM_PAY_OUT_EAES_WORK_EXP where P_CLAIM_PAY_OUT = P_CLAIM_PAY_OUT__;
      --ПРОВЕРЯЕМ ВДРУГ СНЯЛИ ВСЕ ГАЛОЧКИ, ЕСЛИ СНЯЛИ, ТО ИЗ МОРДЫ В ПОЛЕ ID_CODE ПИШЕТСЯ "EmptyArr"
--      select COUNT(1)
--        into CNT_
--        from MAIN.P_CLAIM_PAY_OUT_EAES_ANKETA# EA
--       where EA.ID_CODE = 'EmptyArr';
      --EmptyArr ДОЛЖНА БЫТЬ ОДНА И ПРИ СНЯТИИ ВСЕХ ГАЛОЧЕК, ЕСЛИ БОЛЕЕ 1 ЗАПИСИ, ТОГДА ЛУЧШЕ ЗАПИШЕМ, ЭТО КАКОЙ ТО ГЛЮК, ПРОАНАЛИЗИРУЙТЕ И УДАЛИТЕ НЕНУЖНЫЕ ЗАПИСИ С EmptyArr
--      if CNT_ = 1 then
--        NULL;
--      else
--        for REC IN (
--          Declare ID_CODE_ P_CLAIM_PAY_OUT_EAES_ANKETA.ID_CODE%TYPE;
          begin
--          select EA.ID_CODE INTO ID_CODE_
--                      from MAIN.P_CLAIM_PAY_OUT_EAES_ANKETA# EA;
--        loop
            insert into MAIN.P_CLAIM_PAY_OUT_EAES_ANKETA
              (P_CLAIM_PAY_OUT_EAES_ANKETA, P_CLAIM_PAY_OUT, ID_CODE, G_PERSON, P_CONTRACT, OFFICIAL, SYS_DATE, PARTICIPANTS, REASON_FOR_PETITION, D__EAES_COMPETENT_AUTHORITY
              ,pensionparticipantid, retr_pay_det_indicator,PENSIONRECEIVINGSTATEKINDCODE, ADDITIONALINFOTEXT)
            select SEQ_P_CLAIM_PAY_OUT_EAES_ANKETA.NEXTVAL, P_CLAIM_PAY_OUT__, ID_CODE, G_PERSON_, P_CONTRACT_, CONNECTION_PARAM.IDUSER, SYSDATE,PARTICIPANTS, REASON_FOR_PETITION, D__EAES_COMPETENT_AUTHORITY
               ,pensionparticipantid, retr_pay_det_indicator, PENSIONRECEIVINGSTATEKINDCODE, ADDITIONALINFOTEXT
                              from MAIN.P_CLAIM_PAY_OUT_EAES_ANKETA# EA;
--            values
--              (SEQ_P_CLAIM_PAY_OUT_EAES_ANKETA.NEXTVAL, P_CLAIM_PAY_OUT__, ID_CODE_, G_PERSON_, P_CONTRACT_, CONNECTION_PARAM.IDUSER, SYSDATE);
--            select P_CLAIM_PAY_OUT, ID_CODE
--                              from MAIN.P_CLAIM_PAY_OUT_EAES_ANKETA EA;


          exception
            when others then
              ERR_CODE := -20500;
              ERR_MSG  := PROCNAME || ' ' || PNT_ || ' --> ' || ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, SQLERRM) ||
                          'ОШИБКА ДОБАВЛЕНИЯ ЗАПИСИ В ТАБЛИЦУ MAIN.P_CLAIM_PAY_OUT_EAES_ANKETA';
              --DELETE from MAIN.P_G_CLAIM_PAY_OUT_EAES_ANKETA#;
              raise TYPES.E_FORCE_EXIT;
          end;
--        end loop;
--     end if;
    end if;
    DELETE from MAIN.P_CLAIM_PAY_OUT_EAES_ANKETA#;

    --СОХРАНЯЕМ ВВЕДЕННЫЙ СТАЖ РАБОТЫ ИЗ ТРУДОВОЙ КНИЖКИ
    select COUNT(1)
      into CNT_
      from MAIN.P_CLAIM_PAY_OUT_EAES_WORK_EXP# WE;
    if CNT_ > 0 then
      for REC IN (select WE.* from MAIN.P_CLAIM_PAY_OUT_EAES_WORK_EXP# WE)
      loop
        begin
          insert into MAIN.P_CLAIM_PAY_OUT_EAES_WORK_EXP
            (P_CLAIM_PAY_OUT_EAES_WORK_EXP,
             P_CLAIM_PAY_OUT,
             STATE_OF_EMPLOYMENT,
             KIND_OF_ACTIVITY,
             DT_START,
             DT_END,
             ORG_NAME,
             RegionName,
             DistrictName,
             CityName,
--             ORG_LOCATION_ADDRESS,
             G_PERSON,
             P_CONTRACT,
             OFFICIAL,
             SYS_DATE
             )
          values
            (REC.P_CLAIM_PAY_OUT_EAES_WORK_EXP,
             P_CLAIM_PAY_OUT__,
             REC.STATE_OF_EMPLOYMENT,
             REC.KIND_OF_ACTIVITY,
             REC.DT_START,
             REC.DT_END,
             REC.ORG_NAME,
             REC.RegionName,
             REC.DistrictName,
             REC.CityName,
--             REC.ORG_LOCATION_ADDRESS,
             G_PERSON_,
             P_CONTRACT_,
             CONNECTION_PARAM.IDUSER,
             SYSDATE);
        exception
          when others then
            ERR_CODE := -20500;
            ERR_MSG  := PROCNAME || ' ' || PNT_ || ' --> ' || ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, SQLERRM) ||'ОШИБКА ДОБАВЛЕНИЯ ЗАПИСИ В ТАБЛИЦУ MAIN.P_CLAIM_PAY_OUT_EAES_WORK_EXP';
            --DELETE from MAIN.P_CLAIM_PAY_OUT_EAES_WORK_EXP# WE;
            raise TYPES.E_FORCE_EXIT;
        end;
      end loop;
      DELETE from MAIN.P_CLAIM_PAY_OUT_EAES_WORK_EXP# WE;
    end if;
    -- 03.06.2024 Olzhast                      Добавил сохранение дополнительной инофрмации по анкете заявлению ЕАЭС, Person
   begin
    SELECT COUNT(1)
      INTO CNT_
      FROM MAIN.P_EAES_FORMULAR_PERSON# WE;
      DELETE FROM MAIN.P_EAES_FORMULAR_PERSON WE WHERE WE.P_CLAIM_PAY_OUT = P_CLAIM_PAY_OUT__;
    IF CNT_ > 0 THEN
      FOR REC IN (SELECT WE.* FROM MAIN.P_EAES_FORMULAR_PERSON# WE)
      LOOP
        BEGIN
         INSERT INTO MAIN.P_EAES_FORMULAR_PERSON
                    (P_EAES_FORMULAR_PERSON,
                     P_CLAIM_PAY_OUT,
                     EAES_PERSON_TYPE,
                     LASTNAME,
                     FIRSTNAME,
                     MIDDLENAME,
                     BIRTHDATE,
                     SEXCODE,
                     NATIONALITYCOUNTRYCODE,
                     BIRTHPLACENAME,
                     UNIFIEDCOUNTRYCODE,
                     RegionName,
                     DistrictName,
                     CityName,
                     STREETNAME,
                     BUILDINGNUMBERID,
                     ROOMNUMBERID,
                     Postcode,
                     Tel,
                     Email,
                     PENSIONPARTICIPANTID_KZ,
                     Pensionparticipantid_Ru,
                     Pensionparticipantid_Kg,
                     Pensionparticipantid_By,
                     Pensionparticipantid_Am,
                     LASTNAME_BIRTH,
                     DOCKINDNAME,
                     DOCSERIESID,
                     Docid,
                     Doccreationdate,
                     Docvaliditydate,
                     Doc_Type,
                     AUTHORITYNAME
                     )
                  VALUES
                    (REC.P_EAES_FORMULAR_PERSON,
                     P_CLAIM_PAY_OUT__,
                     REC.EAES_PERSON_TYPE,
                     REC.LASTNAME,
                     REC.FIRSTNAME,
                     REC.MIDDLENAME,
                     REC.BIRTHDATE,
                     REC.SEXCODE,
                     REC.NATIONALITYCOUNTRYCODE,
                     REC.BIRTHPLACENAME,
                     REC.UNIFIEDCOUNTRYCODE,
                     REC.RegionName,
                     REC.DistrictName,
                     REC.CityName,
                     REC.STREETNAME,
                     REC.BUILDINGNUMBERID,
                     REC.ROOMNUMBERID,
                     REC.Postcode,
                     REC.Tel,
                     REC.Email,
                     REC.PENSIONPARTICIPANTID_KZ,
                     REC.Pensionparticipantid_Ru,
                     REC.Pensionparticipantid_Kg,
                     REC.Pensionparticipantid_By,
                     REC.Pensionparticipantid_Am,
                     REC.LASTNAME_BIRTH,
                     REC.DOCKINDNAME,
                     REC.DOCSERIESID,
                     REC.Docid,
                     REC.Doccreationdate,
                     REC.Docvaliditydate,
                     REC.Doc_Type,
                     REC.AUTHORITYNAME
                     );
        EXCEPTION
          WHEN OTHERS THEN
            ERR_CODE := -20500;
            ERR_MSG  := PROCNAME || ' ' || PNT_ || ' --> ' || ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, SQLERRM) ||
                        'ОШИБКА ДОБАВЛЕНИЯ ЗАПИСИ В ТАБЛИЦУ MAIN.P_EAES_FORMULAR_PERSON';
            RAISE TYPES.E_EXECERROR;
        END;
      END LOOP;
      DELETE FROM MAIN.P_EAES_FORMULAR_PERSON# WE;
    END IF;
    SELECT COUNT(1)
      INTO CNT_
      FROM MAIN.P_EAES_FORMULAR_PERSON_DOC# WE;
      DELETE FROM MAIN.P_EAES_FORMULAR_PERSON_DOC WE WHERE WE.P_EAES_FORMULAR_PERSON IN
                      (SELECT P_EAES_FORMULAR_PERSON FROM P_EAES_FORMULAR_PERSON WHERE P_CLAIM_PAY_OUT =P_CLAIM_PAY_OUT__);
    IF CNT_ > 0 THEN
        BEGIN
                 INSERT INTO MAIN.P_EAES_FORMULAR_PERSON_DOC
                    (P_EAES_FORMULAR_PERSON,
                     P_EAES_FORMULAR_PERSON_DOC,
                     DOCKINDNAME,
                     DOCSERIESID,
                     Docid,
                     Doccreationdate,
                     Docvaliditydate,
                     Doc_Type,
                     AUTHORITYNAME
                     )
                  SELECT
                     P_EAES_FORMULAR_PERSON,
                     P_EAES_FORMULAR_PERSON_DOC,
                     DOCKINDNAME,
                     DOCSERIESID,
                     Docid,
                     Doccreationdate,
                     Docvaliditydate,
                     Doc_Type,
                     AUTHORITYNAME
                     FROM P_EAES_FORMULAR_PERSON_DOC#;
        EXCEPTION
          WHEN OTHERS THEN
            ERR_CODE := -20500;
            ERR_MSG  := PROCNAME || ' ' || PNT_ || ' --> ' || ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, SQLERRM) ||
                        'ОШИБКА ДОБАВЛЕНИЯ ЗАПИСИ В ТАБЛИЦУ MAIN.P_EAES_FORMULAR_PERSON_DOC';
            RAISE TYPES.E_EXECERROR;
        END;
      DELETE FROM MAIN.P_EAES_FORMULAR_PERSON_DOC#;
    END IF;

   -- OlzhasT Сохраняем Сведения о факте получения пенсий трудящимся
    SELECT COUNT(1)
      INTO CNT_
      FROM MAIN.P_EAES_RETRIEMENT# WE;
      DELETE FROM MAIN.P_EAES_RETRIEMENT WE WHERE WE.p_Claim_Pay_Out =P_CLAIM_PAY_OUT__;
    IF CNT_ > 0 THEN
        BEGIN
          INSERT INTO P_EAES_RETRIEMENT
            (P_CLAIM_PAY_OUT, P_EAES_RETRIEMENT, UNIFIEDCOUNTRYCODE, TERRITORIALSUBDIVISIONNAME, PENSIONKINDCODE, STARTDATETIME, ENDDATETIME)
           SELECT
             P_CLAIM_PAY_OUT__, P_EAES_RETRIEMENT, UNIFIEDCOUNTRYCODE, TERRITORIALSUBDIVISIONNAME, PENSIONKINDCODE, STARTDATETIME, ENDDATETIME
           FROM P_EAES_RETRIEMENT#;
        EXCEPTION
          WHEN OTHERS THEN
            ERR_CODE := -20500;
            ERR_MSG  := PROCNAME || ' ' || PNT_ || ' --> ' || ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, SQLERRM) ||
                        'ОШИБКА ДОБАВЛЕНИЯ ЗАПИСИ В ТАБЛИЦУ MAIN.P_EAES_RETRIEMENT';
            RAISE TYPES.E_EXECERROR;
        END;
      DELETE FROM MAIN.P_EAES_RETRIEMENT#;
    END IF;

   end;

  end if;



  --Значения вставки--
  pnt_ := '10';
  vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' '||pnt_;
--  old_val_:=Adm.Utils_Pack.Get_OLD_Data('MAIN', 'P_Claim_Pay_Out' , 'P_Claim_Pay_Out', P_Claim_Pay_Out__, DATA_OLD_TABLE);
  Adm.Audit_Pack.Ins(1054,'Добавлено заявление Id: ' || P_Claim_Pay_Out__||' Номер заявления '||claim_num_||', Дата заявления '||To_Char(date_registr_, 'dd.mm.yyyy'), ' '/*old_val_*/,P_Claim_Pay_Out_,Audit_Event_,Errcode,Errmsg);
  if Errcode <> 0 then
    raise types.e_Execerror;
  end if;


  -- 04.04.2023    Тайканов Е.Р.   -- Для заявлений на поргебение проверка остатков и создание дополнительных заявлений
  if P_G_PAY_OUT_TYPE_ = 3 and mode_ = 0 then
    if nvl(main.pension_pack.vpiRecursion,0) = 0 then
      main.pension_pack.vpiRecursion := 1;
      declare
        type Tl_NumberArray                 is table of number index by binary_integer;  -- Tl_ значит локально. Вдруг кто нить создасть глобальную TNumberArray
        -- ProcName                            constant  Types.TProc_Name :='P_INSERT_CLAIM_PAY_OUT';
        -- pnt_                                varchar2(5);
        -- P_G_PAY_OUT_TYPE_                   P_G_PAY_OUT_TYPE.P_G_PAY_OUT_TYPE%TYPE;
        SUM_BURIAL_                         NUMBER;
        MRP_                                MAIN.G_MINIMAL_DESIGN_INDEX.VALUE % TYPE;
        MP_                                 MAIN.G_MINIMAL_DESIGN_INDEX.VALUE % TYPE;
        working_date_                       number;
        work_date_                          date;
        Contract_Owner_                     number;
        P_G_PAY_OUT_SUB_TYPE_ADD_           number;
        Owner_Contr_List                    TYPES.TSTRINGARRAY;
        Owner_Contr_Saldo                   Tl_NumberArray;
        vliUE_COURSE                        number;
        vliTMP                              number := 0;
        P_CLAIM_PAY_OUT_ADD_                number;
        vliContractKND                      number;
      begin
        begin
          select w.working_date, w.work_date
            into working_date_, work_date_
            from MAIN.WORKING_DATE W
           where W.IS_ACTIVE = 1;
        exception when others then
            Err_Code := -20500;
            ERR_MSG := adm.error_pack.GET_ERR_MSG_SHORT('0000',
                                                       ProcName || ' pnt_ ' || pnt_,
                                                       Err_Code,
                                                       'Не удалось вычислить предыдущий опердень.');
            raise TYPES.E_EXECERROR;
        end;

        select c.g_person_recipient
        into Contract_Owner_
        from   main.p_contract c
        where  c.p_contract = P_CONTRACT_;

        MRP_ := MAIN.PENSION_PACK.GET_MRP_SUMM(DATE_ => work_date_, ERR_CODE => ERR_CODE, ERR_MSG  => ERR_MSG);
        MP_ := MAIN.PENSION_PACK.GET_MIN_PENSION_SUMM(DATE_ => work_date_, ERR_CODE => ERR_CODE, ERR_MSG  => ERR_MSG);
        vliUE_COURSE := nvl(MAIN.K_CURRENCY_COURSE_PACK.GET_PENSION_COURSE_REC(1, WORKING_DATE_),0);
        Owner_Contr_Saldo(0) := 0;
        SUM_BURIAL_ := 94 * MRP_;

        for CONTR IN (select *
                      from (select ROUND(vliUE_COURSE * NVL(PENSION_PACK.GET_ACCOUNT_OUTPUT_CU(MAIN.PENSION_PACK.P_GET_G_ACCOUNT_IPC(C.P_CONTRACT, 1), working_date_, working_date_), 0), 2) AS SALDO,
                                   C.P_CONTRACT,
                                   C.p_g_Contract_Knd,
                                   CASE P_G_CONTRACT_KND when 10 then 1
                                                         when 18 then 2
                                                         else  3 end AS ORDER_BY_KND
                            from   MAIN.P_CONTRACT C
                            where  C.G_PERSON_RECIPIENT = Contract_Owner_
                                   and C.DATE_CLOSE IS NULL
                                   --AND C.P_CONTRACT != P_CONTRACT_
                                   and C.P_G_CONTRACT_KND IN (10, 11, 18))
                      order by ORDER_BY_KND
                     )

        loop
          SUM_TAX_DEFERRAL_ := PENSION_PACK.GET_SUMM_TAX_DEFERRAL_DATE(P_CONTRACT_ => CONTR.P_CONTRACT,
                                                                       DATE_ID_ => WORKING_DATE_,
                                                                       DATE_ => NULL);
          Owner_Contr_Saldo(0) := Owner_Contr_Saldo(0) + NVL(CONTR.SALDO, 0) - SUM_TAX_DEFERRAL_;

          if CONTR.P_CONTRACT != P_CONTRACT_ and NVL(CONTR.SALDO, 0) > 0 then  -- В массив берем все кроме текущего контракта и с положительным остатком.
            Owner_Contr_List(CONTR.P_G_CONTRACT_KND) := CONTR.P_CONTRACT;
            Owner_Contr_Saldo(CONTR.P_G_CONTRACT_KND) := NVL(CONTR.SALDO, 0) - SUM_TAX_DEFERRAL_;
          end if;

          if CONTR.P_CONTRACT = P_CONTRACT_ then
            vliTMP := NVL(CONTR.SALDO, 0) - SUM_TAX_DEFERRAL_; -- Остаток контракта, на котором создали заявление.
          end if;

        end loop;

        vliContractKND := Owner_Contr_List.FIRST;

        while (vliContractKND IS NOT NULL)
        loop
         -- Создаем дополнительные заявления если общий остаток меньше 52,4*МРП + 1*МП или по уже созданным заявлениям остаток меньше 52,4.
         if Owner_Contr_Saldo(0) < SUM_BURIAL_ + MP_ or vliTMP < SUM_BURIAL_ then
            vliTMP := vliTMP + Owner_Contr_Saldo(vliContractKND);

            select P_G_PAY_OUT_SUB_TYPE
            into   P_G_PAY_OUT_SUB_TYPE_ADD_
            from   main.p_g_pay_out_sub_type st
            where  st.p_g_pay_out_type = 3
                   and st.is_taxfree = 0
                   and st.is_active = 1
                   and st.p_g_contract_type = vliContractKND;

            P_INS_CLAIM_PAY_OUT(
               P_CLAIM_PAY_OUT_INITIAL_    ,
               Owner_Contr_List(vliContractKND) ,  -- Подменяем это
               G_PERSON_                   ,
               P_G_CLAIM_PAY_OUT_KND_      ,
               P_G_PAY_OUT_SUB_TYPE_ADD_   ,  -- Подменяем это
               G_TYPE_PERIOD_              ,
               P_G_REGISTRATION_TYPE_      ,
               P_G_REGISTRATION_PLACE_     ,
               IS_SEND_MAIL_               ,
               DATE_PAPER_                 ,
               DATE_RECEPTION_             ,
               DATE_REGISTR_               ,
               HERITAGE_PERCENT_FORMAL_    ,
               HERITAGE_PERCENT_REAL_      ,
               HERITAGE_QUANTITY_          ,
               PRIVILEGE_IS_HAVE_          ,
               PRIVILEGE_DATE_END_         ,
               P_G_ANALYTICTYPES_          ,
               P_G_ANALYTICCODES_          ,
               BANK_G_JUR_PERSON_          ,
               G_JUR_PERSON_ACC_           ,
               BANK_IS_FOREIGN_            ,
               BANK_BY_POST_               ,
               BANK_IS_CARD_ACCOUNT_       ,
               BANK_BIK_                   ,
               BANK_RNN_                   ,
               BANK_ACCOUNT_               ,
               BANK_ACCOUNT_PERSONAL_      ,
               BANK_IS_RECIPIENT_ACCOUNT_  ,
               BANK_BRANCH_NAME_           ,
               BANK_BRANCH_CODE_           ,
               BANK_FOREIGN_KPP_           ,
               BANK_FOREIGN_ACCOUNT_       ,
               BANK_NAME_                  ,
               G_CURRENCY_                 ,
               P_G_TRUSTEE_                ,
               WARRANT_NUMBER_             ,
               WARRANT_begin_DATE_         ,
               WARRANT_END_DATE_           ,
               FM_                         ,
               NM_                         ,
               FT_                         ,
               DT_                         ,
               RNN_                        ,
               IDN_                        ,
               G_RESIDENTS_                ,
               G_COUNTRY_                  ,
               G_SEX_                      ,
               ADDRESS_                    ,
               MOBPHONERASS_               ,
               EMAILRASS_                  ,
               PHONE_                      ,
               G_ID_KIND_                  ,
               ID_SERIAL_                  ,
               ID_NUM_                     ,
               ID_DATE_                    ,
               ID_ISSUER_                  ,
               IS_INCOMPETENT_             ,
               HERITAGE_IS_PERCENT_CORRECT_,
              P_REESTR_KZ_                 ,
               FMTrustee_                  ,
               NMTrustee_                  ,
               FTTrustee_                  ,
               DTTrustee_                  ,
               AddressTrustee_             ,
               G_ID_KIND_Trustee_          ,
               ID_SERIAL_Trustee_          ,
               ID_NUM_Trustee_             ,
               ID_DATE_Trustee_            ,
               ID_ISSUER_Trustee_          ,
               RNNTrustee_                 ,
               IDNTrustee_                 ,
              -- данные доверителя         ,
               FMSettlor_                  ,
               NMSettlor_                  ,
               FTSettlor_                  ,
               DTSettlor_                  ,
               G_ID_KIND_Settlor_          ,
               ID_SERIAL_Settlor_          ,
               ID_NUM_Settlor_             ,
               ID_DATE_Settlor_            ,
               ID_ISSUER_Settlor_          ,
               RNNSettlor_                 ,
               IDNSettlor_                 ,
               AddressSettlor_             ,
              --                           ,
               IS_PREDSTAVITEL_            ,
               G_RESIDENTS_TRUSTEE_        ,
               G_RESIDENTS_SETTLOR_        ,
               BANK_INTERMED_NAME_         ,
               BANK_INTERMED_SWIFT_        ,
               BANK_INTERMED_ACC_          ,
               TRUST_OSNOVANIE_            ,
              -- представитель юрлица      ,
               FMJURPREDSTAVITEL_          ,
               NMJURPREDSTAVITEL_          ,
               FTJURPREDSTAVITEL_          ,
               IDDOCPREDSTAVITEL_          ,
               DOCNUMPREDSTAVITEL_         ,
               DOCDATEPREDSTAVITEL_        ,
               APPOINTPREDSTAVITEL_        ,
              -- новые поля из ЗАЯВКИ №2, П
               CARDNUM_                    ,
               SORTCODE_                   ,
               BANK_COUNTRY_               ,
               FM_LAT_                     ,
               NM_LAT_                     ,
               FT_LAT_                     ,
               NO_FT_                      ,
               NO_FT2_                     ,
               IS_HAVE_RIGHT_REG_OLD_LAW__ , -- 24.02.20258 OlzhasT
               AMOUNT_                     ,
               AMOUNT_IS_MANUAL_           ,
              P_INGOING_PARSED_P01_        ,
              IDN_CHILD_                   ,
              mode_                        ,
              NUMBERGK_                    ,
              DATEGK_                      ,
              G_DISTRICT_                  ,
              QUEUE_NUM_                   ,
              DATE_PAY_RESTART_            ,
              PHONE_PENS_                  ,
              PAYS_IS_STOPPED_GK_          ,
              G_REASON_PAY_STOP_GK_        ,
              REASON_PAY_STOP_GK_          ,
              PAYS_IS_STOPPED_ENPF_        ,
              G_REASON_PAY_STOP_ENPF_      ,
              REASON_PAY_STOP_ENPF_        ,
              G_OFFICIAL_PAY_STOPPED_      ,
              IS_HAVE_TAX_DEDUCTION_       ,
              P_INGOING_PARSED_PENS_       ,
              DATE_PAY_STOP_GK_            ,
              G_PERSON_RECIPIENT_          ,
              G_PERSON_TRUSTEE_            ,
              G_PERSON_SETTLOR_            ,
              ID_DATE_END_                 ,
              ID_DATETRUSTEE_END_          ,
              ID_DATESETTLOR_END_          ,
              P_LT_GBDFL_PERSON_DEP_       ,
              P_LT_GBDFL_PERSON_REC_       ,
              P_LT_GBDFL_PERSON_TRUSTEE_   ,
              P_LT_GBDFL_PERSON_SETTLOR_   ,
              PRIVILEGE_DATE_begin_        ,
              FIRST_MONTH_                 ,
              P_G_RELATION_DEGREE_         ,
              IS_HAVE_RELATION_DEGREE_     ,
              g_residents_country_         ,
              do_commit_                   ,
              P_CLAIM_PAY_OUT_ADD_         , -- Подменяем это. Так как первый созданый ID нужен для возврата в клиентское приложение.
              Err_Code                     , -- OUT TYPES.TErr_Code,
              Err_Msg                       -- OUT TYPES.TErr_Msg
            );

          end if;
          vliContractKND := Owner_Contr_List.NEXT (vliContractKND);
        end loop;
      end;
      main.pension_pack.vpiRecursion := Null;
      -- 04.04.2023    Тайканов Е.Р.  -- Удаляем тут по заявлениям "на погребение"
      delete from k_attached_doc#;
      delete from p_claim_pay_out_form_att_doc#;
      --10.12.2024: Миреев А. п.3 Плана ДЦ на 3 и 4 кв.2024г. - Реализация алгоритмов замораживания операций по переводу / выплате накоплений физического лица или его представителя или получателя (погребение) или наследника, включенных в Перечни
      M__FTE_FROMU.P_SEND_TO_LEGAL_DEPARTMENT_FOR_CONSIDERATION(CLAIM_ID_ => TO_NUMBER(P_CLAIM_PAY_OUT_),
                                                                CLAIM_SAVE_MODE_ => 1001,
                                                                P_G_PAY_OUT_TYPE_ => P_G_PAY_OUT_TYPE_);
      if do_commit_ = 1 then
        commit;
      end if;
    end if;
  else
    -- 04.04.2023    Тайканов Е.Р.   -- Удаляем тут для заявлений кроме "на погребение"
    delete from k_attached_doc#;
    delete from p_claim_pay_out_form_att_doc#;
    --10.12.2024: Миреев А. п.3 Плана ДЦ на 3 и 4 кв.2024г. - Реализация алгоритмов замораживания операций по переводу / выплате накоплений физического лица или его представителя или получателя (погребение) или наследника, включенных в Перечни
    M__FTE_FROMU.P_SEND_TO_LEGAL_DEPARTMENT_FOR_CONSIDERATION(CLAIM_ID_ => TO_NUMBER(P_CLAIM_PAY_OUT_),
                                                              CLAIM_SAVE_MODE_ => 1001,
                                                              P_G_PAY_OUT_TYPE_ => P_G_PAY_OUT_TYPE_);
    if do_commit_ = 1 then
      commit;
    end if;
  end if;
    <<end_ins_claim_pay_out>>  --pnt_ := '000'
   main.pp_Save_ERROR('P_INS_CLAIM_PAY_OUT[Ok] ['||DBMS_UTILITY.FORMAT_CALL_STACK||'] USERENV['||nvl(Upper(SYS_CONTEXT('USERENV','OS_USER')),'**')||'] vlcLogs['||Trim(vlcLogs)||'] ['||SUBSTR(SQLERRM,1,1000)||']');
null;
exception
  when Types.e_Execerror then
    main.pp_Save_ERROR('P_INS_CLAIM_PAY_OUT[Types.e_Execerror] ['||nvl(Dbms_Utility.FORMAT_ERROR_BACKTRACE,'-=NULL=-') ||'] ['||DBMS_UTILITY.FORMAT_CALL_STACK||'] USERENV['||nvl(Upper(SYS_CONTEXT('USERENV','OS_USER')),'**')||'] vlcLogs['||Trim(vlcLogs)||'] ['||SUBSTR(SQLERRM,1,1000)||']');
    PENSION_PACK.P_Claim_Is_Created_By_Gk := NULL;    -- ВОЗВРАЩАЮ ПАКЕТНУЮ ПЕРЕМЕННУЮ В NULL ОБРАТНО 15.06.2018 Темеков АА Задача 192926
    PENSION_PACK.P_G_Pay_Out_Type := NULL;            -- ВОЗВРАЩАЮ ПАКЕТНУЮ ПЕРЕМЕННУЮ В NULL ОБРАТНО 17.07.2018 Темеков АА
    rollback;
    Adm.Audit_Pack.Upd(Audit_Event_, 0, Err_Code, Err_Msg, Adm.Utils_Pack.Get_Data_Row_Table('MAIN','P_Claim_Pay_Out' , 'P_Claim_Pay_Out', P_Claim_Pay_Out_),NULL,Errcode,Errmsg);
  when others then
    main.pp_Save_ERROR('P_INS_CLAIM_PAY_OUT['||nvl(Dbms_Utility.FORMAT_ERROR_BACKTRACE,'-=NULL=-') ||'] ['||DBMS_UTILITY.FORMAT_CALL_STACK||'] USERENV['||nvl(Upper(SYS_CONTEXT('USERENV','OS_USER')),'**')||'] vlcLogs['||Trim(vlcLogs)||'] ['||SUBSTR(SQLERRM,1,1000)||']');
    Err_Code := SQLCODE;
    Err_Msg  := ProcName||' pnt_ '||pnt_||' --> '|| Adm.Error_Pack.Get_Err_Msg('0000', Err_Code, SQLERRM)|| 'Ошибка вставки заявления';
    PENSION_PACK.P_Claim_Is_Created_By_Gk := NULL;    -- ВОЗВРАЩАЮ ПАКЕТНУЮ ПЕРЕМЕННУЮ В NULL ОБРАТНО 15.06.2018 Темеков АА Задача 192926
    PENSION_PACK.P_G_Pay_Out_Type := NULL;            -- ВОЗВРАЩАЮ ПАКЕТНУЮ ПЕРЕМЕННУЮ В NULL ОБРАТНО 17.07.2018 Темеков АА
    rollback;
    Adm.Audit_Pack.Upd(Audit_Event_, 0, Err_Code, Err_Msg, Adm.Utils_Pack.Get_Data_Row_Table('MAIN','P_Claim_Pay_Out' , 'P_Claim_Pay_Out', P_Claim_Pay_Out_),NULL,Errcode,Errmsg);
END P_INS_CLAIM_PAY_OUT;
/
