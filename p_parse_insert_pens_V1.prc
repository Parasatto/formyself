CREATE OR REPLACE PROCEDURE p_parse_insert_pens(
  P_INGOING_XML_            IN  NUMBER, -- яяшкйю мю бундъыхи XML тюик. кхан рср ID, кхан б онке BODY_ - яюл XML тюик
  BODY_                     IN  CLOB,   -- рекн PENS, рнкэйн рекн, аег рпюмяонпрмни хмтнплюжхх
  MESSAGE_ID_               IN  VARCHAR2,
  RESPONSE_ID_              IN  VARCHAR2,
  DO_COMMIT_                IN  NUMBER, -- 1-декюрэ COMMIT, 0-ме декюрэ COMMIT
  P_INGOING_PARSED_PENS_    OUT NUMBER,
  BLOB_DATA_                OUT BLOB,
  ERR_CODE                  OUT NUMBER, 
  ERR_MSG                   OUT VARCHAR2
) IS
  PROCNAME CONSTANT TYPES.TPROC_NAME := 'P_PARSE_INSERT_PENS';
--  PNT_     VARCHAR2(5);
  ----------------------------------------------------------------------------------------------
  -- оПНЖЕДСПЮ ПЮГАНПЮ РЕКЮ XML ТЮИКЮ PENS
  -- юБРНПЯРБН ОПЕМЮДКЕФХР релейнбс ю.ю.
  ----------------------------------------------------------------------------------------------
  -- хярнпхъ хглемемхи:
  -- дюрю        йрн            COMMENTS  цде хглемъкняэ
  ----------------------------------------------------------------------------------------------
  -- 11.04.2018 людшаюеб л.  сбеднлкемхе хг юхя лхмхярепярбю б юхя емот н ондюве гюъбкемхъ мю оемяхнммше бшокюрш он опхвхме днярхфемхъ оемяхнммнцн бнгпюярю
  -- 08.10.2018 релейнб юю,  гюдювю 187980, днцнбнп рд рнфе мюдн свхршбюрэ
  -- 15.10.2018 релейнб юю   гюдювю 274952 мюдн апюрэ гюъбкемхе хг люяяхбю
  -- 25.10.2018 релейнб юю,  гюдювю 192926, гюъбкемхе мюдн янгдюбюрэ рнкэйн мю рнл днцнбнпе, мю йнрнпнл мер деиярбсчыецн гюъбкемхъ
  -- 25.10.2018 релейнб юю,  гюдювю 192926, пегхдемрярбн он тнплюрс рнкэйн 0 хкх 1
  -- 10.12.2018 релейнб юю,  гюдювю 273413, хглемемхъ, ябъгюммше я мюкнцюлх, онъбхкяъ юбрнлюрхвеяйхи гюопня P00, опхйпеокемхе пегскэрюрю
  -- 01.04.2019 релейнб юю,  гюдювю 326287, онк опнбепърэ рнфе
  -- 06.08.2019 аШВЙНБ л.    ДНПЮАНРЙЮ ДКЪ ГЮОСЯЙЮ ОХКНРМШУ ОПНЮЙРХБМШУ БШОКЮР ДКЪ ПЮАНРМХЙНБ цй
  -- 11.09.2019 аШВЙНБ л.    Б СЙЮГЮММНИ ДЮРЕ ОНЪБХКНЯЭ ДБЮ ПЕЕЯРПЮ (P_REESTR) Я НДМХЛ МНЛЕПНЛ (REESTR_NUM=00-20190911-0911), PENS ЯКНЛЮКЯЪ - ОПХЬКНЯЭ БШАХПЮРЭ ЛХМХЛЮКЭМШИ ID
  -- 31.01.2019 аШВЙНБ л.    ДНАЮБКЕМЮ БНГЛНФМНЯРЭ НАПЮАЮРШБЮРЭ ХЯЙКЧВЕМХЪ: ХГЛЕМЪРЭ БН БУНДЪЫХУ ГЮЪБКЕМХЪУ PENS ДЮРС ОПХЕЛЮ ГЮЪБКЕМХЪ
  --                         ОПХ ПЕЦХЯРПЮЖХХ ГЮЪБКЕМХЪ Б P_CLAIM_PAY_OUT.DATE_RECEPTION
  --                         ЯОХЯНЙ ФЕМЫХМ, ОН ЙНРНПШЛ ДНКФМШ ПЮАНРЮРЭ ХЯЙКЧВЕМХЪ ГЮПЮМЕЕ ДНКФЕМ АШРЭ БМЕЯЕМ Б РЮАКХВЙС P_exception_PENS
  -- 27.04.2020 Ekopylov         гЮДЮВЮ 509954, ЕЯКХ БЯЕ УНПНЬН РН НРОПЮБКЪЕЛ Б НВЕПЕДЭ МЮ ОПНБЕПЙС Б цадтк
  -- 06.05.2020 люлернб я.ю.     он гюдюве б ахрпхйяе ╧512143 дя ╧ 2 х дя ╧ 3 й янцкюьемхч н бгюхлндеиярбхх я цй: тсмйжхнмюк он опхлемемхч мюкнцнбнцн бшверю й
  --                             оемяхнммшл бшокюрюл он бнгпюярс вепег цй (PENS). 48.  нясыеярбкемхе бшокюр вепег цй б яннрберярбхх я сярюмнбкеммшл цй цпютхйнл оемяхнммшу бшокюр
  --                             (б вюярх хяйкчвемхъ нясыеярбкемхъ оепбни бшокюрш б ревемхе 10 пюанвху дмеи, б яксвюе хглемемхи б опюбхкю 1042)

  -- 27.05.2020  лЮЛЕРНБ я.ю.    бЕПМСК МЮГЮД КНЦХЙС БШВХЯКЕМХЪ ДЮРШ ДНЯРХФЕМХЪ ОЕМЯ БНУПЮЯРЮ, ЙНРНПЮЪ АШКЮ ЯЙНППЕРХПНБЮММЮ 31.01.2019 аШВЙНБ л.
  -- 03.06.2020  йЕКДЕЬЕБ ю.ю.   гЮДЮВЮ514116, еЯКХ ЯХЯРЕЛМЮЪ НЬХАЙЮ, МЮОПХЛЕП ДНЯРСОЮ МЕР Й ХЯРНПХВЕЯЙНИ АЮГЕ, РН ЛШ ЯНУПЮМЪЕЛ Б ЙНЛЕМРЮПХХ Й ГЮЪБКЕМХЧ МЮ БШОКЮРС
  -- 15.10.2020  люлернб яепхй   он пюанре янблеярмнцн опхйюгю, хгзърхх яопюбнй н ялепрх, ашкх днаюбкемш оюпюлерпш P_G_RELATION_DEGREE_ х IS_HAVE_RELATION_DEGREE_ б опнжедспс
  -- 04.02.2021  люлернб яепхй   он гюдюве б ахрпхйяе 591156 "бМЕЯЕМХЕ ХГЛЕМЕМХИ Б ОПНБЕПЙХ ОН ЛЕЯЪЖС ОЕПБНИ БШОКЮРШ ОПХ НАПЮАНРЙЕ ТЮИКНБ PENS"
  --                             яг руюб-5887 НР 03.02.2021, О.7.2 оПХ ОНКСВЕМХХ ТНПЛЮРЮ PENS САПЮРЭ ОПНБЕПЙС, ЕЯКХ ЛЕЯЪЖ ОЕПБНИ БШОКЮРШ ПЮБЕМ ЛЕЯЪЖС ОНДЮВХ ГЮЪБКЕМХЪ цй.
  -- 01.04.2021  люлернб яепхй   б ПЮЛЙЮУ ГЮДЮВХ Б АХРПХЙЯЕ ╧ 599199 ПЮГПЮАНРЙЮ Х ПЕЮКХГЮЖХЪ ТСМЙЖХНМЮКЮ ОН ПЮЯВЕРС ПЮГЛЕПЮ ОЕМЯХНММШУ БШОКЮР
  --                             Б ЯННРБЕРЯРБХХ Я ЛЕРНДХЙНИ НЯСЫЕЯРБКЕМХЪ ПЮЯВЕРЮ ПЮГЛЕПЮ ОЕМЯХНММШУ БШОКЮР ОНЪБХКЮЯЭ МЕНАУНДХЛНЯРЭ ОПНБЕПЪРЭ МЮКХВХЕ ХМБЮКХДМНЯРХ ОН ЙЮФДНЛС БЙКЮДВХЙС/ОНКСВЮРЕКЧ
  --                             ХГ ТЮИКЮ pens МЮ МЮКХВХЕ КЭЦНРШ
  -- 21.05.2021  люлернб яепхй   бМЕЯКХ ХГЛЕМЕМХЪ Б НОПЕДЕКЕМХЪ ДЮРЮ ОПХЕЛЮ ГЮЪБКЕМХЪ ДКЪ ГЮЪБКЕМХХ Я ОПХГМЮЙНЛ ОПНЮЙРХБМЮЪ СЯКСЦЮ
  -- 13.07.2022  AnvarT          бШГНБ JOB-Ю ГЮЛЕМХК МЮ СМХБЕПЯЮКЭМСЧ ОПНЖЕДСПС ЙНРНПЮЪ ПЮАНРЮЕР Я DBMS_SCHEDULER Р.Й. 19 БЕПЯХЪ НПЮЙКЮ МЕ ОНДДЕПФХБЮЕР МНПЛЮКЭМН СЯРЮПЕБЬХИ JOB
  -- 12.09.2022  AnvarT          мЮБЕЯХК НРКЮДНВМНИ ХМТНПЛЮЖХХ
  -- 25.09.2023: лХПЕЕБ ю.       ЙНЦДЮ ЯНГДЮЕРЯЪ ГЮЪБКЕМХЕ ДНАЮБХК ЯНГДЮМХЕ ЯНЦКЮЬЕМХЪ МЮ НАПЮАНРЙС ДЮММШУ
  -- 15.12.2023  аШВЙНБ л.       пЕЮКХГСЕЛ БНГЛНФМНЯРЭ ОПХЕЛЮ ГЮЪБКЕМХИ МЮ БШОКЮРС ОН нямя
  -- 10.12.2024  аШВЙНБ          я СВЕРНЛ ГЮОНГДЮКНИ НРОПЮБЙХ Й МЮЛ ХГ цй ГЮЪБКЕМХИ ОН нямя,
  --                             ОЕПЕЯРЮКЮ ПЮАНРЮРЭ МЮЬЮ КНЦХЙЮ ЙНМРПНКЪ ЙНППЕЙРМНЯРХ ОНКЪ FirstMonth МЮ ЯРШЙЕ КЕР
  --                             оНЩРНЛС ЯРЮПСЧ КНЦХЙС Ъ ЛЕМЪЧ
  -- 03.07.2025 Y.Kisseleva      P_CHECK_PAY_CLAIM_PARAMS  ДНАЮБХКЯЪ МНБШИ  out ОЮПЮЛЕРП IS_CHECK_RELATION_DEGREE_
  -- 04.09.2025 аШВЙНБ           мЕНАУНДХЛН ОПХМХЛЮРЭ ГЮЪБКЕМХЪ ОН БНГПЮЯРС ОПХ МЮКХВХХ МЕГЮЙПШРНЦН ГЮЪБКЕМХЪ ОН нямя
  --                              Б ЯБЪГХ Я ХГЛЕМЕМХЪЛХ Б оПЮБХКЮУ ╧521
  -- 22.10.2025 Y.Kisseleva      B BLOCK_ := '17 - хглемемхе гюъбкемхъ'; ОНЯРЮБХКЮ РЮЙ НАNULLЪКНЯЭ  NVL(CONNECTION_PARAM.IDUSER, 100)
  ----------------------------------------------------------------------------------------------

  BLOCK_                         VARCHAR2(255);
  DT_                            DATE;
  APPLYDATEGK_                   DATE;
  DT_KIDS_                       DATE;
  INVALIDITYbeginDATE_           DATE;
  INVALIDITYENDDATE_             DATE;
  DATE_from_PRIVILEGE_           DATE;
  DATE_TO_PRIVILEGE_             DATE;
  DATE_TRANS_ADOPTIVE_FM_        DATE;
  DATE_END_TRANS_ADOPTIVE_FM_    DATE;
  FILE_BODY_                     BLOB;
  ID_LOB_                        NUMBER;

  CNT_                           NUMBER;
  V_ERR_CODE                     NUMBER;
  V_ERR_MSG                      VARCHAR2(1024);

  BODY_FILE_                     CLOB;
  P_OUTGOING_PARSED_PENSO_       NUMBER;
  IIN_                           VARCHAR2(20);
  P_OUTGOING_XML_                NUMBER;
  DOM_                           DBMS_XMLDOM.DOMDOCUMENT;
  ROOT_NODE_                     DBMS_XMLDOM.DOMNODE;
  ELEMENT_                       DBMS_XMLDOM.DOMELEMENT;
  NODE_                          DBMS_XMLDOM.DOMNODE;
  NODE_TEXT                      DBMS_XMLDOM.DOMTEXT;
  PENSO_NODE_                    DBMS_XMLDOM.DOMNODE;
  EMPLOYEE_NODE_                 DBMS_XMLDOM.DOMNODE;
  PENSO_BODY_                    XMLTYPE;
  DATA_                          CLOB;
  result_                        NUMBER;
  P_INGOING_PARSED_ZON_          P_INGOING_PARSED_ZON.P_INGOING_PARSED_ZON%TYPE;
  PROC_SIGN_                     P_INGOING_PARSED_PENS.PROCEED_SIGN%TYPE;
  ERRMSGARR                      K_TYPES.TERRMSGARR;
  NEGATIVEMSGCNT_                INTEGER := 0;
  ERRMSGARRяREGULAR              K_TYPES.TERRMSGARR;
  ERRMSGARRяREGULAROUR           K_TYPES.TERRMSGARR;
  WARNMSGARR                     K_TYPES.TERRMSGARR;
  WARNMSGARRяREGULAR             K_TYPES.TERRMSGARR;
  P_CONTRACTARR_                 K_TYPES.TNUMBERARRAY;
  I                              INTEGER;
  G_PERSON_                      G_NAT_PERSON.G_PERSON%TYPE;
  P_G_PAY_OUT_SUB_TYPE_          P_G_PAY_OUT_SUB_TYPE.P_G_PAY_OUT_SUB_TYPE%TYPE;
  DATE_RECEPTION_                DATE;
  DATE_REGISTR_                  DATE;
  DATE_PAPER_                    DATE;
  G_PERSON_REC                   G_NAT_PERSON%ROWTYPE;
  P_CLAIM_PAY_OUT_               P_CLAIM_PAY_OUT.P_CLAIM_PAY_OUT%TYPE;
  G_RESIDENTS_                   INTEGER;
  G_COUNTRY_                     G_COUNTRY.G_COUNTRY%TYPE;
  P_REESTR_                      P_REESTR.P_REESTR%TYPE;
  P_CLAIM_PAY_OUT_ARR_           K_TYPES.TNUMBERARRAY;
  P                              INTEGER := 0;
  PREPAY_SUMM_                   NUMBER := 0;
  PREPAY_SUMM_ALL_               NUMBER := 0;
  NEGATIVEMSG_                   VARCHAR2(30000);
  P_G_CONTRACT_KND_              P_G_CONTRACT_KND.P_G_CONTRACT_TYPE%TYPE;
  P_CONTRACT_OPV_                P_INGOING_PARSED_PENS.P_CONTRACT_OPV%type;
  P_CLAIM_PAY_OUT_OPV_           P_INGOING_PARSED_PENS.P_CLAIM_PAY_OUT_OPV%type;
  P_CONTRACT_OPPV_               P_INGOING_PARSED_PENS.P_CONTRACT_OPPV%type;
  P_CLALIM_PAY_OUT_OPPV_         P_INGOING_PARSED_PENS.P_CLALIM_PAY_OUT_OPPV%type;
  P_CONTRACT_DPV_                P_INGOING_PARSED_PENS.P_CONTRACT_DPV%TYPE;
  P_CLAIM_PAY_OUT_DPV_           P_INGOING_PARSED_PENS.P_CLAIM_PAY_OUT_DPV%TYPE;
  MOBPHONERASS_                  P_CLAIM_PAY_OUT.MOBPHONERASS%TYPE;
  CrLf                           varchar2(2) := chr(13)||chr(10);
  -- ОЕПЕЛЕММШЕ ДКЪ ОПНБЕПЙХ ТНПЛЮРЮ
  -- 0 - мнпл, 1 - мюпсьемн, 2 - гмюй, врн бярюбкърэ б рюакхжс P_INGOING_PARSED_PENS ме мсфмн
  IS_NUM_FIO_WRONG_              INTEGER := 0;
  IS_DATE_DT_WRONG_              INTEGER := 0;
  IS_DATE_APPLYDATEGK_WRONG_     INTEGER := 0;
  IS_NUM_IIN_WRONG_              INTEGER := 0;
  IS_NUM_POL_WRONG_              INTEGER := 0;
  IS_NUM_QUEUE_WRONG_            INTEGER := 0;
  IS_NUM_DEDUCT_WRONG_           INTEGER := 0;
  IS_NUM_RESIDENCE_WRONG_        INTEGER := 0;
  IS_NUM_DISTRICT_WRONG_         INTEGER := 0;
  IS_MOBPHONE_WRONG_             INTEGER := 0;
  IS_HOMEPHONE_WRONG_            INTEGER := 0;
  IS_APPLYNUMBERGK_WRONG_        INTEGER := 0;
  IS_iMETHOD_WRONG_              INTEGER := 0;
  IS_PRIVILEGES_WRONG_           INTEGER := 0;
  IS_PRIVILEGES_KIDS_WRONG_      INTEGER := 0;
  IS_FIRSTMONTH_WRONG_           INTEGER := 0;
  IS_paymentsType_WRONG_         INTEGER := 0; -- 15.12.2023
  IS_includeOPV_WRONG_           INTEGER := 0; -- 15.12.2023
  HAS84OPPV_                     INTEGER := 0; -- 15.12.2023
  -----

--  SUMREMAIN_                     NUMBER := 0;

  --10.12.2018 релейнб юю, гюдювю 273413, хглемемхъ, ябъгюммше я мюкнцюлх
  ANSWER_WASNT_SUCCESS_          INTEGER := 0;    -- нрлерйю н хмбюкхдмнярх еярэ, мн P00 месяоеьмн
  P_INGOING_PARSED_P01_          VARCHAR(20) := NULL;
  DISABILITY_                    P_INGOING_PARSED_P01.DISABILITY%TYPE;
  DISABILITY_VALIDITY_DATE_      P_INGOING_PARSED_P01.DISABILITY_VALIDITY_DATE%TYPE := NULL;
  PRIVILEGE_IS_HAVE_             P_CLAIM_PAY_OUT.PRIVILEGE_IS_HAVE%type := 0;
  PRIVILEGE_DATE_END_            P_CLAIM_PAY_OUT.PRIVILEGE_DATE_END%type := null;
  PRIVILEGE_DATE_begin_          P_CLAIM_PAY_OUT.PRIVILEGE_DATE_END%type := null;
  P_G_ANALYTICTYPES_             P_G_ANALYTICTYPES.P_G_ANALYTICTYPES%TYPE := NULL;
  P_G_ANALYTICCODES_             P_G_ANALYTICCODES.P_G_ANALYTICCODES%TYPE := NULL;
  P_INGOING_PARSED_PENS_PRIVIL_  NUMBER;
  IS_WORK_FIRST_MONTH_FILE_PENS_ INTEGER := 0;
  FIRST_DAY_PENS_AGE_            DATE;

  ERRCODE                        NUMBER;
  ERRMSG                         VARCHAR2(1000);
  ERRMSGGK                       VARCHAR2(1000);
  Warn_CODE                      TYPES.TERR_CODE;
  Warn_MSG                       TYPES.TERR_MSG;
  --30.01.2020 аШВЙНБ л., ОПНАКЕЛШ Я ФЕМЫХМЮЛХ ДНЯРХЦЬХЛХ Б 2019 БНГПЮЯРЮ, МН Б 2020 СФЕ МЕ ХЛЕЧЫХЕ ОПЮБЮ МЮ ОЕМЯХЧ
  P_exception_PENS_              NUMBER; -- хЛЕЕРЯЪ ХЯЙКЧВЕМХЕ - ПЮЯОНПЪФЕМХЕ Н ОПХЕЛЕ ГЮЪБКЕМХЪ Я ДЮРНИ, ПЮМЭЬЕ ТЮЙРХВЕЯЙНИ
  EXC_APPLYDATEGK_               Date;   -- дЮРЮ ОПХЕЛЮ ГЮЪБКЕМХЪ (ХГ ХЯЙКЧВЕМХЪ), ЙНРНПНИ МСФМН ОНДЛЕМХРЭ ТЮЙРХВЕЯЙСЧ

  vlcLogs                  clob;
  vlcLogStep               clob;
  IS_CHECK_RELATION_DEGREE_ NUMBER;
  ----------------------------------------------------------------------------------------------
  function IS_NUMBER (STR_   VARCHAR2)
  return INTEGER IS
    NUM_ NUMBER;
  begin
    NUM_ := TO_NUMBER(STR_);
    return 1;
  exception
    when others then
      return 0;
  end;

  ----------------------------------------------------------------------------------------------
  procedure pl_InsERROR(P_INGOING_PARSED_PENS_ IN P_INGOING_PARSED_PENS.P_INGOING_PARSED_PENS%TYPE,
                        ERR_CODE_              IN INTEGER,
                        ERR_MSG_               IN P_INGOING_PARSED_PENS_ERR.ERR_MSG_ENPF%TYPE,
                        ERR_MSG_GK_            IN P_INGOING_PARSED_PENS_ERR.ERR_MSG_GK%TYPE
                        )
  IS begin
      insert into MAIN.P_INGOING_PARSED_PENS_ERR(
             P_INGOING_PARSED_PENS_ERR,
             P_INGOING_PARSED_PENS,
             ERR_CODE,
             ERR_MSG_ENPF,
             ERR_MSG_GK
             )
      values(SEQ_P_INGOING_PARSED_PENS_ERR.NEXTVAL, -- 1
             P_INGOING_PARSED_PENS_,
             ERR_CODE_,
             ERR_MSG_,
             ERR_MSG_GK_);
  end;
  ----------------------------------------------------------------------------------------------
  procedure CALL_P00(IDN_  IN VARCHAR2)
  is pragma AUTONOMOUS_TRANSACTION;
    V_SQL    VARCHAR2(1024);
--    N_JOB    NUMBER;
  begin
    V_SQL := 'DECLARE
                CODE_                     VARCHAR2(121);
                P_INGOING_PARSED_P01_     NUMBER;
                OUTGOING_ID_              VARCHAR2(121);
                INGOING_ID_               VARCHAR2(121);
                ERR_CODE                  NUMBER;
                ERR_MSG                   VARCHAR2(3200);
              begin
                P_INSERT_XML_P00(IIN_ => ' || IDN_|| ',
                                 CODE_ => CODE_,
                                 P_INGOING_PARSED_P01_ => P_INGOING_PARSED_P01_,
                                 OUTGOING_ID_ => OUTGOING_ID_,
                                 INGOING_ID_ => INGOING_ID_,
                                 ERR_CODE => ERR_CODE,
                                 ERR_MSG => ERR_MSG);
              end;';

    -- DBMS_JOB.SUBMIT(N_JOB, V_SQL, SYSDATE);
    main.pp_Job_Execute(V_SQL,'оПНЖЕДСПЮ ПЮГАНПЮ РЕКЮ XML ТЮИКЮ PENS P_PARSE_INSERT_PENS.CALL_P00');
    commit;
  exception
    when others then
      NULL;
  end;

begin
  ERR_CODE := 0;
  ERR_MSG := '';
  ERRCODE := 0;
  ERRMSG  := '';

  vlcLogs     := vlcLogs||chr(10)||to_char(systimestamp,'hh24:mi:ss.FF')||' Start'
                     ||'P_INGOING_XML_['||P_INGOING_XML_||']'
                     ||'MESSAGE_ID_['||MESSAGE_ID_||']'
                     ||'RESPONSE_ID_['||RESPONSE_ID_||']'
                     ||'DO_COMMIT_['||DO_COMMIT_||']';


  ----------------------------------------------------------------------------------------------
  -- 25.07.2018 релейнб юю оНЙЮ МЕ ОЕПЕИДЕЛ МЮ ПЕФХЛ ПЮАНРШ Я цй - ОНЯРЮБКЧ ГЮЦКСЬЙС, МЕ АСДС ЛСДПХРЭ Х ОПНЯРН ПЮГДЕКЧ МЮ ДБЕ БЕРЙХ
  -- Х БЕРЙС-ГЮЦКСЬЙС БНГЭЛС Я ПЕЮКЭМНИ
  ----------------------------------------------------------------------------------------------
  if PARAMS.GET_SYSTEM_SETUP_PARAM('GK_MODE_ON') = 0 then           -- берйю гюцксьйю
    WITH TMP AS (select BODY_ DATA from DUAL)
      select TRIM_SMART(STM.IIN)
      into IIN_
      from TMP, XMLTABLE(XMLNAMESPACES(DEFAULT ''),
                    '//PENS' PASSING XMLTYPE(TMP.DATA)
                    COLUMNS IIN   VARCHAR2(20)  path 'IIN'
                   ) STM;

    BLOCK_ := '14 - янупюмъел гюопня оепед нропюбйни б цжбо';
    insert into MAIN.P_OUTGOING_XML(P_OUTGOING_XML,MESSAGE_ID,CORRELATION_ID,MESSAGE_TYPE,DATA,SYS_DATE,STATUS,ERR_MSG)
    values (SEQ_P_OUTGOING_XML.NEXTVAL, RESPONSE_ID_, MESSAGE_ID_, 'PENSO', NULL, SYSDATE, 1, NULL )
    returning P_OUTGOING_XML into P_OUTGOING_XML_;

    BLOCK_ := '15 - бярюбйю б дерюкх хяундъыецн нрберю ';
    -- дкъ бярюбйх б дерюкх мсфмю опедбюпхрекэмюъ ясллю бшокюрш, ю щрн ясллюпмне гмювемхе оепбни бшокюрш
    -- он цпютхйс он бяел гюъбкемхъл мю бшокюрс, бшвхякъеряъ бшье
    result_ := 0;

    BLOCK_ := '16 - янгдюмхе мнбнцн XML днйслемрю';
    DOM_ := DBMS_XMLDOM.NEWDOMDOCUMENT;
    ROOT_NODE_ := DBMS_XMLDOM.MAKENODE(DOM_);

    -- ROOT-рщц "PENSO"
    BLOCK_ := '17 - тнплхпнбюмхе йнпмебнцн рщцю PENSO';
    ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'PENSO');
    PENSO_NODE_ := DBMS_XMLDOM.APPENDCHILD(ROOT_NODE_,DBMS_XMLDOM.MAKENODE(ELEMENT_));

    -- ххм
    BLOCK_ := '18 - тнплхпнбюмхе йнпмебнцн рщцю IIN';
    ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'IIN');
    NODE_ := DBMS_XMLDOM.APPENDCHILD(PENSO_NODE_, DBMS_XMLDOM.MAKENODE(ELEMENT_));
    NODE_TEXT := DBMS_XMLDOM.CREATETEXTNODE(DOM_, IIN_);
    NODE_ := DBMS_XMLDOM.APPENDCHILD(NODE_, DBMS_XMLDOM.MAKENODE(NODE_TEXT));

    -- result
    BLOCK_ := '19 - тнплхпнбюмхе йнпмебнцн рщцю result';
    ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'result');
    NODE_ := DBMS_XMLDOM.APPENDCHILD(PENSO_NODE_, DBMS_XMLDOM.MAKENODE(ELEMENT_));
    NODE_TEXT := DBMS_XMLDOM.CREATETEXTNODE(DOM_, result_);

    NODE_ := DBMS_XMLDOM.APPENDCHILD(NODE_, DBMS_XMLDOM.MAKENODE(NODE_TEXT));

    BLOCK_ := '20 - тнплхпнбюмхе йнпмебнцн рщцю resultMESSAGE';
    ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'resultMessage');
    NODE_ := DBMS_XMLDOM.APPENDCHILD(PENSO_NODE_, DBMS_XMLDOM.MAKENODE(ELEMENT_));
    NODE_TEXT := DBMS_XMLDOM.CREATETEXTNODE(DOM_, 'дН БЯРСОКЕМХЪ Б ЯХКС ХГЛЕМЕМХИ Б мою, ПЕЦКЮЛЕМРХПСЧЫХУ ОНПЪДНЙ НЯСЫЕЯРБКЕМХЪ ОЕМЯХНММШУ БШОКЮР ОН БНГПЮЯРС ХГ емот, МЕНАУНДХЛН НАПЮЫЮРЭЯЪ Я ГЮЪБКЕМХЕЛ Н МЮГМЮВЕМХХ ОЕМЯХНММШУ БШОКЮР Б емот');
    NODE_ := DBMS_XMLDOM.APPENDCHILD(NODE_, DBMS_XMLDOM.MAKENODE(NODE_TEXT));

    -- SUMM
    BLOCK_ := '21 - тнплхпнбюмхе йнпмебнцн рщцю SUMM';
    ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'summ');
    NODE_ := DBMS_XMLDOM.APPENDCHILD(PENSO_NODE_, DBMS_XMLDOM.MAKENODE(ELEMENT_));
    NODE_TEXT := DBMS_XMLDOM.CREATETEXTNODE(DOM_, '0');
    NODE_ := DBMS_XMLDOM.APPENDCHILD(NODE_, DBMS_XMLDOM.MAKENODE(NODE_TEXT));

    -- тхн НРБЕРЯРБЕММНЦН КХЖЮ, ОНЙЮ МЕ ЯЙЮГЮКХ НРЙСДЮ АПЮРЭ
    BLOCK_ := '21.1 - тнплхпнбюмхе йнпмебнцн рщцю EMPLOYEE';
    ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'employee');
    EMPLOYEE_NODE_ := DBMS_XMLDOM.APPENDCHILD(PENSO_NODE_, DBMS_XMLDOM.MAKENODE(ELEMENT_));

    declare
      lastName_    G_JUR_PERSON.Chief_Fm%type;
      firstName_   G_JUR_PERSON.CHIEF_NM%type;
      middleName_  G_JUR_PERSON.CHIEF_FT%type;
      position_    G_JUR_PERSON.Chief_Appointment%type;
      bin_         G_JUR_PERSON.IDN%TYPE;
    begin
      begin
        select JP.CHIEF_FM, JP.CHIEF_NM, JP.CHIEF_FT, JP.CHIEF_APPOINTMENT, PARAMS.GET_SYSTEM_SETUP_PARAM('CHIEF_IDN')
          into lastName_, firstName_, middleName_, position_, bin_
          from G_JUR_PERSON JP
         where JP.IDN = '971240002115'
           and JP.PENS_FOND_CODE = '24';
      exception
        when others then
          null;
      end;

      BLOCK_ := '21.2 - тнплхпнбюмхе йнпмебнцн рщцю POSITION';
      ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'position');
      NODE_ := DBMS_XMLDOM.APPENDCHILD(EMPLOYEE_NODE_, DBMS_XMLDOM.MAKENODE(ELEMENT_));
      NODE_TEXT := DBMS_XMLDOM.CREATETEXTNODE(DOM_, position_);
      NODE_ := DBMS_XMLDOM.APPENDCHILD(NODE_, DBMS_XMLDOM.MAKENODE(NODE_TEXT));

      BLOCK_ := '21.3 - тнплхпнбюмхе йнпмебнцн рщцю LASTNAME';
      ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'lastName');
      NODE_ := DBMS_XMLDOM.APPENDCHILD(EMPLOYEE_NODE_, DBMS_XMLDOM.MAKENODE(ELEMENT_));
      NODE_TEXT := DBMS_XMLDOM.CREATETEXTNODE(DOM_, lastName_);
      NODE_ := DBMS_XMLDOM.APPENDCHILD(NODE_, DBMS_XMLDOM.MAKENODE(NODE_TEXT));

      BLOCK_ := '21.4 - тнплхпнбюмхе йнпмебнцн рщцю FIRSTNAME';
      ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'firstName');
      NODE_ := DBMS_XMLDOM.APPENDCHILD(EMPLOYEE_NODE_, DBMS_XMLDOM.MAKENODE(ELEMENT_));
      NODE_TEXT := DBMS_XMLDOM.CREATETEXTNODE(DOM_, firstName_);
      NODE_ := DBMS_XMLDOM.APPENDCHILD(NODE_, DBMS_XMLDOM.MAKENODE(NODE_TEXT));

      BLOCK_ := '21.5 - тнплхпнбюмхе йнпмебнцн рщцю MIDDLENAME';
      ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'middleName');
      NODE_ := DBMS_XMLDOM.APPENDCHILD(EMPLOYEE_NODE_, DBMS_XMLDOM.MAKENODE(ELEMENT_));
      NODE_TEXT := DBMS_XMLDOM.CREATETEXTNODE(DOM_, middleName_);
      NODE_ := DBMS_XMLDOM.APPENDCHILD(NODE_, DBMS_XMLDOM.MAKENODE(NODE_TEXT));

      BLOCK_ := '21.6 - тнплхпнбюмхе йнпмебнцн рщцю IIN';
      ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'IIN');
      NODE_ := DBMS_XMLDOM.APPENDCHILD(EMPLOYEE_NODE_, DBMS_XMLDOM.MAKENODE(ELEMENT_));
      NODE_TEXT := DBMS_XMLDOM.CREATETEXTNODE(DOM_, bin_);
      NODE_ := DBMS_XMLDOM.APPENDCHILD(NODE_, DBMS_XMLDOM.MAKENODE(NODE_TEXT));
    end;

    BLOCK_ := '22 - опенапюгнбюмхе онксвеммнцн XML б CLOB';
    PENSO_BODY_ := DBMS_XMLDOM.GETXMLTYPE(DOM_);
    DATA_ := PENSO_BODY_.GETCLOBVAL;

    update MAIN.P_OUTGOING_XML
       SET DATA = DATA_
     where P_OUTGOING_XML = P_OUTGOING_XML_;

    BLOB_DATA_ := MAIN.CLOB_TO_BLOB(MAIN.KAK_GET_CORRECT_UTF_KAZ(DATA_));

  else   --- if PARAMS.GET_SYSTEM_SETUP_PARAM('GK_MODE_ON') = 0 then       -- берйю пеюкэмюъ, оняке оепеундю мю пефхл пюанрш я цй
    BLOCK_ := '01 - сярюмнбйю оюпюлерпнб янедхмемхъ';
    if CONNECTION_PARAM.IDUSER IS NULL then
      CONNECTION_PARAM.SET_PARAMS(ERRCODE, ERRMSG);
      if ERRCODE <> 0 then
        ERRCODE := ERRCODE;
        ERR_MSG := PROCNAME || ' 010 --> ' || ERRMSG;
        raise TYPES.E_FORCE_EXIT;
      end if;
    end if;
    CONNECTION_PARAM.IDUSER := 100;  -- онкэгнбюрекэ цй
    CONNECTION_PARAM.IDFILIAL := 0;  -- жемрпюкэмши юооюпюр


    begin               -- оПХГМЮЙ РНЦН, ВРН МЮВЮКХ ПЮАНРС БШОКЮР ЯНЦКЮЯМН ЛЕЯЪЖС ОЕПБНИ БШОКЮРШ Х ВРН МСФМН ОПНИРХ БЕЯЭ ЖХЙК ОПНБЕПНЙ ЯНЦКЮЯМН ОГ
      IS_WORK_FIRST_MONTH_FILE_PENS_ := ADM.PARAMS.GET_SYSTEM_SETUP_PARAM('IS_WORK_FIRST_MONTH_FILE_PENS');
    exception
      when others then
        IS_WORK_FIRST_MONTH_FILE_PENS_ := 0;
    end;

    if P_INGOING_XML_ IS NOT NULL and BODY_ IS NULL then
      select A.DATA
      into BODY_FILE_
      from MAIN.P_INGOING_XML A
      where P_INGOING_XML = P_INGOING_XML_;
    else
      BODY_FILE_ := BODY_;
    end if;

    if BODY_FILE_ IS NULL then
      BLOCK_ := 'рекн яннаыемхъ PENS осярне';
      raise TYPES.E_FORCE_EXIT;
    end if;

    BLOCK_ := '03 - онксвемхе дюммшу ндмнцн бйкюдвхйю, мейнппейрмши XML';
    for REC_DETAIL IN (
                select TRIM_SMART(STM.IIN) IIN, -- ххм
                       TRIM_SMART(STM.FM) FM, -- тюлхкхъ
                       TRIM_SMART(STM.NM) NM, -- хлъ
                       TRIM_SMART(STM.FT) FT, -- нрвеярбн
                       TRIM_SMART(STM.DT) DT, -- дюрю пнфдемхъ
                       TRIM_SMART(STM.SEX) SEX,
                       TRIM_SMART(STM.MOBILEPHONE) MOBILEPHONE,
                       TRIM_SMART(STM.HOMEPHONE) HOMEPHONE,
                       TRIM_SMART(STM.EMAIL) EMAIL,
                       NVL(TRIM_SMART(STM.PAYMENTSTYPE),'1')  PAYMENTSTYPE,   -- 15.12.2023
                       TRIM_SMART(STM.INCLUDEOPV)    INCLUDEOPV,     -- 15.12.2023
                       TRIM_SMART(STM.APPLYNUMBERGK) APPLYNUMBERGK,
                       TRIM_SMART(STM.APPLYDATEGK)   APPLYDATEGK,
                       TRIM_SMART(STM.QUEUE) QUEUE,
                       TRIM_SMART(STM.DEDUCTION) DEDUCTION,
                       TRIM_SMART(STM.RESIDENCE) RESIDENCE,
                       TRIM_SMART(STM.DISTRICT) DISTRICT,
                       TO_NUMBER(NVL(STM.iMETHOD,'666')) iMETHOD, -- аШВЙНБ л. ДНАЮБХК 06.08.2019
                       DECODE(IS_WORK_FIRST_MONTH_FILE_PENS_, 0, NULL, TRIM_SMART(STM.FIRSTMONTH)) FIRSTMONTH
                       --NVL(STM.PRIVILEGES, NULL) AS PRIVILEGES
                  from XMLTABLE(XMLNAMESPACES(DEFAULT ''),
                                --xmlnamespaces(default 'http://www.swapInfo.kz'),
  --                                '//(p01|p02)' PASSING XMLTYPE(BODY_FILE_)
                                '//PENS' PASSING XMLTYPE(BODY_FILE_)
                                --'SLD/statement/detail' PASSING INPUT_XML_DATA_
                                COLUMNS IIN             VARCHAR2(20)  path 'IIN',
                                        FM              VARCHAR2(61)  path 'surname',
                                        NM              VARCHAR2(61)  path 'name',
                                        FT              VARCHAR2(61)  path 'patronymic',
                                        DT              VARCHAR2(30)  path 'birthDate',
                                        SEX             VARCHAR2(20)  path 'gender',
                                        MOBILEPHONE     VARCHAR2(50)  path 'mobilePhone',
                                        HOMEPHONE       VARCHAR2(50)  path 'homePhone',
                                        EMAIL           VARCHAR2(50)  path 'email',
                                        PAYMENTSTYPE    VARCHAR2(3)   path 'paymentsType',  -- 15.12.2023 аШВЙНБ л. рЕОЕПЭ АШБЮЧР ПЮГМШЕ РХОШ
                                        INCLUDEOPV      VARCHAR2(3)   path 'includeOPV',    -- 15.12.2023 аШВЙНБ л. дКЪ БШОКЮР нямя СЙЮГШБЮЕРЯЪ, ОКЮРХРЭ КХ ноб
                                        APPLYNUMBERGK   VARCHAR2(20)  path 'applyNumberGK',
                                        APPLYDATEGK     VARCHAR2(30)  path 'applyDateGK',
                                        QUEUE           VARCHAR2(30)  path 'queue',
                                        DEDUCTION       VARCHAR2(30)  path 'deduction',
                                        RESIDENCE       VARCHAR2(30)  path 'residence',
                                        DISTRICT        VARCHAR2(30)  path 'district',
                                        iMETHOD         VARCHAR2(1)   path 'initiationMethod',
                                        FIRSTMONTH      VARCHAR2(2)   path 'firstMonth' -- 06.05.2020 лЮЛЕРНБ я.ю
                                        --PRIVILEGES      CLOB          path 'privileges' -- 06.05.2020 лЮЛЕРНБ я.ю

                               ) STM
                      ) loop
      ----------------------------------------------------------------------------------------------
      -- опнбепйю тнплюрю гюопняю
      ----------------------------------------------------------------------------------------------
      -- опнбепйю initiationMethod -- ДНАЮБКЕМН 06.08.2019 аШВЙНБ л.
      if REC_DETAIL.IMETHOD NOT IN (1, 2) then -- 15.08.2019 ХЯЙКЧВХКХ ДНОСЯРХЛНЯРЭ 3, Р.Й. e-gov ЕЫ╦ МЕ БМЕДП╦М, Ю цй ОПХЯКЮКХ 3 (ЙНЯЪВМХЙХ)
        if REC_DETAIL.IMETHOD = 666 then
          ERRMSG := 'мюпсьем тнплюр яннаыемхъ PENS. нрясрярбсер гмювемхе наъгюрекэмнцн оюпюлерпю initiationMethod'||CrLf;
          ERRMSGGK := 'мюпсьем тнплюр яннаыемхъ PENS. нрясрярбсер гмювемхе наъгюрекэмнцн оюпюлерпю initiationMethod'||CrLf;
        else
          ERRMSG := 'мюпсьем тнплюр яннаыемхъ PENS. онке initiationMethod яндепфхр медносярхлне гмювемхе'||CrLf;
          ERRMSGGK := 'мюпсьем тнплюр яннаыемхъ PENS. онке initiationMethod яндепфхр медносярхлне гмювемхе'||CrLf;
        end if;
        IS_iMETHOD_WRONG_ := 1;
      -- опнбепйю ххм
      elsif REC_DETAIL.IIN IS NULL then
        ERRMSG := 'мюпсьем тнплюр яннаыемхъ PENS. онке ххм ме гюонкмемн'||CrLf;
        ERRMSGGK := 'мюпсьем тнплюр яннаыемхъ PENS. онке ххм ме гюонкмемн'||CrLf;
        IS_NUM_IIN_WRONG_ := 1;
      elsif LENGTH(REC_DETAIL.IIN) <> 12 then
        ERRMSG := 'мюпсьем тнплюр яннаыемхъ PENS. онке ххм днкфмн ашрэ 12 яхлбнкнб'||CrLf;
        ERRMSGGK := 'мюпсьем тнплюр яннаыемхъ PENS. онке ххм днкфмн ашрэ 12 яхлбнкнб'||CrLf;
        IS_NUM_IIN_WRONG_ := 1;
      else
        if IS_NUMBER(REC_DETAIL.IIN) = 0 then
          ERRMSG := 'мюпсьем тнплюр яннаыемхъ PENS. онке ххм яндепфхр ме жхтпнбше яхлбнкш'||CrLf;
          ERRMSGGK := 'мюпсьем тнплюр яннаыемхъ PENS. онке ххм яндепфхр ме жхтпнбше яхлбнкш'||CrLf;
          IS_NUM_IIN_WRONG_ := 1;
        end if;
      end if;

      -- опнбепйю тхн
      if REC_DETAIL.FM IS NULL and REC_DETAIL.NM IS NULL and REC_DETAIL.FT IS NULL then
        ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. тхн ме гюонкмемн'||CrLf;
        ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. тхн ме гюонкмемн'||CrLf;
        ERRCODE := 3;
        PROC_SIGN_ := 3;
        --GOTO INS_DETAILS;
        IS_NUM_FIO_WRONG_ := 1;
      else      -- опнбепч врн тхн ме яндепфхр жхтп
        DECLARE
          NUM_ SMALLINT;
        begin
          select 1
          into NUM_
          from dual
          where REGEXP_LIKE(NVL(REC_DETAIL.FM, 'A')||NVL(REC_DETAIL.NM, 'A')||NVL(REC_DETAIL.FT, 'A'), '[0-9]');

          ERRCODE := 3;
          ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. тхн яндепфхр жхтпш'||CrLf;
          ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. тхн яндепфхр жхтпш'||CrLf;
          PROC_SIGN_ := 3;
          --GOTO INS_DETAILS;
          IS_NUM_FIO_WRONG_ := 1;
        exception
          when others then
            NULL;
        end;
      end if;

      -- опнбепйю дюрш пнфдемхъ
      if REC_DETAIL.DT IS NULL then
        ERRCODE := 3;
        ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю пнфдемхъ" ме гюонкмемн'||CrLf;
        ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю пнфдемхъ" ме гюонкмемн'||CrLf;
        PROC_SIGN_ := 3;
        --GOTO INS_DETAILS;
        IS_DATE_DT_WRONG_ := 1;
      else
        BLOCK_ := '04 - опенапюгнбюмхе ярпнйнбни хмтнплюжхх б рхохгхпнбюммсч';
        begin
          DT_ := To_Date(SUBSTR(REC_DETAIL.DT,1,10), 'YYYY-MM-DD');
        exception
          when others then
            begin
              DT_ := To_Date(SUBSTR(REC_DETAIL.DT,1,10), 'DD.MM.YYYY');
            exception
              when others then
                ERRCODE := 3;
                ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю пнфдемхъ" мейнппейрмн'||CrLf;
                ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю пнфдемхъ" мейнппейрмн'||CrLf;
                PROC_SIGN_ := 3;
                --GOTO INS_DETAILS;
                IS_DATE_DT_WRONG_ := 2;
            end;
        end;
      end if;

      -- опнбепйю онкю
      if REC_DETAIL.SEX IS NULL then
        ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "онк" ме гюонкмемн'||CrLf;
        ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "онк" ме гюонкмемн'||CrLf;
        IS_NUM_POL_WRONG_ := 1;
      elsif IS_NUMBER(REC_DETAIL.SEX) = 0 then
        ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "онк" яндепфхр ме жхтпнбше яхлбнкш'||CrLf;
        ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "онк" яндепфхр ме жхтпнбше яхлбнкш'||CrLf;
        IS_NUM_POL_WRONG_ := 2;
      elsif REC_DETAIL.SEX NOT IN ('0', '1') then
        ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "онк" днкфмн яндепфюрэ 0 хкх 1'||CrLf;
        ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "онк" днкфмн яндепфюрэ 0 хкх 1'||CrLf;
        IS_NUM_POL_WRONG_ := 1;
      end if;

      -- опнбепйю лнахкэмнцн рекетнмю
      if LENGTH(REC_DETAIL.MOBILEPHONE) <> 12 then
        ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "лнахкэмши рекетнм" днкфмн яндепфюрэ 12 яхлбнкнб'||CrLf;
        ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "лнахкэмши рекетнм" днкфмн яндепфюрэ 12 яхлбнкнб'||CrLf;
        IS_MOBPHONE_WRONG_ := 1;
      elsif INSTR(REC_DETAIL.MOBILEPHONE, '+7') = 0 then
        ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "лнахкэмши рекетнм" днкфмн мювхмюрэяъ я "+7"'||CrLf;
        ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "лнахкэмши рекетнм" днкфм мювхмюрэяъ я "+7"'||CrLf;
        IS_MOBPHONE_WRONG_ := 1;
      end if;

      -- опнбепйю днлюьмецн рекетнмю
      if LENGTH(REC_DETAIL.HOMEPHONE) <> 12 then
        ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "днлюьмхи рекетнм" днкфмн яндепфюрэ 12 яхлбнкнб'||CrLf;
        ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "днлюьмхи рекетнм" днкфмн яндепфюрэ 12 яхлбнкнб'||CrLf;
        IS_HOMEPHONE_WRONG_ := 1;
      elsif INSTR(REC_DETAIL.HOMEPHONE, '+7') = 0 then
        ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "днлюьмхи рекетнм" днкфмн мювхмюрэяъ я "+7"'||CrLf;
        ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "днлюьмхи рекетнм" днкфм мювхмюрэяъ я "+7"'||CrLf;
        IS_HOMEPHONE_WRONG_ := 1;
      end if;

      -- опнбепйю paymentsType -- ДНАЮБКЕМН 15.12.2023 аШВЙНБ л.
      if REC_DETAIL.PAYMENTSTYPE is null then
        ERRMSG   := 'мюпсьем тнплюр яннаыемхъ PENS. нрясрярбсер гмювемхе наъгюрекэмнцн оюпюлерпю paymentsType'||CrLf;
        ERRMSGGK := 'мюпсьем тнплюр яннаыемхъ PENS. нрясрярбсер гмювемхе наъгюрекэмнцн оюпюлерпю paymentsType'||CrLf;
        IS_paymentsType_WRONG_ := 1;
      else
        if IS_NUMBER(REC_DETAIL.PAYMENTSTYPE) = 0 then
          ERRMSG   := 'мюпсьем тнплюр яннаыемхъ PENS. онке paymentsType яндепфхр медносярхлне гмювемхе'||CrLf;
          ERRMSGGK := 'мюпсьем тнплюр яннаыемхъ PENS. онке paymentsType яндепфхр медносярхлне гмювемхе'||CrLf;
          IS_paymentsType_WRONG_ := 2;
        elsif REC_DETAIL.PAYMENTSTYPE not in (1, 3) then
          ERRMSG   := 'мюпсьем тнплюр яннаыемхъ PENS. онке paymentsType яндепфхр медносярхлне гмювемхе'||CrLf;
          ERRMSGGK := 'мюпсьем тнплюр яннаыемхъ PENS. онке paymentsType яндепфхр медносярхлне гмювемхе'||CrLf;
          IS_paymentsType_WRONG_ := 1;
        else
          if REC_DETAIL.PAYMENTSTYPE = 3 then
            if REC_DETAIL.INCLUDEOPV is null then
              ERRMSG   := 'мюпсьем тнплюр яннаыемхъ PENS. нрясрярбсер гмювемхе наъгюрекэмнцн оюпюлерпю includeOPV'||CrLf;
              ERRMSGGK := 'мюпсьем тнплюр яннаыемхъ PENS. нрясрярбсер гмювемхе наъгюрекэмнцн оюпюлерпю includeOPV'||CrLf;
              IS_includeOPV_WRONG_ := 1;
            elsif IS_NUMBER(REC_DETAIL.INCLUDEOPV) = 0 then
              ERRMSG   := 'мюпсьем тнплюр яннаыемхъ PENS. онке includeOPV яндепфхр медносярхлне гмювемхе'||CrLf;
              ERRMSGGK := 'мюпсьем тнплюр яннаыемхъ PENS. онке includeOPV яндепфхр медносярхлне гмювемхе'||CrLf;
              IS_includeOPV_WRONG_ := 2;
            elsif REC_DETAIL.INCLUDEOPV not in (0, 1) then
              ERRMSG   := 'мюпсьем тнплюр яннаыемхъ PENS. онке includeOPV яндепфхр медносярхлне гмювемхе'||CrLf;
              ERRMSGGK := 'мюпсьем тнплюр яннаыемхъ PENS. онке includeOPV яндепфхр медносярхлне гмювемхе'||CrLf;
              IS_includeOPV_WRONG_ := 1;
            end if;
          end if;
        end if;
      end if;
      if REC_DETAIL.INCLUDEOPV is not null then
        if IS_NUMBER(REC_DETAIL.INCLUDEOPV) = 0 then
          ERRMSG   := 'мюпсьем тнплюр яннаыемхъ PENS. онке includeOPV яндепфхр медносярхлне гмювемхе'||CrLf;
          ERRMSGGK := 'мюпсьем тнплюр яннаыемхъ PENS. онке includeOPV яндепфхр медносярхлне гмювемхе'||CrLf;
          IS_includeOPV_WRONG_ := 2;
        end if;
      end if;

      -- опнбепйю мнлепю гюъбкемхъ
      if REC_DETAIL.APPLYNUMBERGK IS NULL then
        ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "мнлеп гюъбкемхъ мю бшокюрш" ме гюонкмемн'||CrLf;
        ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "мнлеп гюъбкемхъ мю бшокюрш" ме гюонкмемн'||CrLf;
        IS_APPLYNUMBERGK_WRONG_ := 1;
      end if;

      -- опнбепйю дюрш гюъбкемхъ
      if REC_DETAIL.APPLYDATEGK IS NULL then
        ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю пецхярпюжхх гюъбкемхъ" ме гюонкмемн'||CrLf;
        ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю пецхярпюжхх гюъбкемхъ" ме гюонкмемн'||CrLf;
        IS_DATE_APPLYDATEGK_WRONG_ := 1;
      else
        begin
          APPLYDATEGK_ := To_Date(SUBSTR(REC_DETAIL.APPLYDATEGK,1,10), 'YYYY-MM-DD');
        exception
          when others then
            begin
              APPLYDATEGK_ := To_Date(SUBSTR(REC_DETAIL.APPLYDATEGK,1,10), 'DD.MM.YYYY');
            exception
              when others then
                ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю пецхярпюжхх гюъбкемхъ" мейнппейрмн'||CrLf;
                ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю пецхярпюжхх гюъбкемхъ" мейнппейрмн'||CrLf;
                IS_DATE_APPLYDATEGK_WRONG_ := 2;
            end;
        end;
      end if;

      -- опнбепйю щрюою
      if REC_DETAIL.QUEUE IS NULL then
        ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "щрюо бшокюрш" ме гюонкмемн'||CrLf;
        ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "щрюо бшокюрш" ме гюонкмемн'||CrLf;
        IS_NUM_QUEUE_WRONG_ := 1;
      elsif IS_NUMBER(REC_DETAIL.QUEUE) = 0 then
        ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "щрюо бшокюрш" яндепфхр межхтпнбше яхлбнкш'||CrLf;
        ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "щрюо бшокюрш" яндепфхр межхтпнбше яхлбнкш'||CrLf;
        IS_NUM_QUEUE_WRONG_ := 2;
      end if;

      -- 21.12.2018 релейнб юю гюдювю 277243, яберкюмю яйюгюкю мюдн мскк опхмхлюрэ йюй мер кэцнрш
      -- опнбепйю бшверю
      /*if REC_DETAIL.DEDUCTION IS NULL then
        ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "янцкюяхе мю опхлемемхе мюкнцнбнцн бшверю" ме гюонкмемн'||CrLf;
        ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "янцкюяхе мю опхлемемхе мюкнцнбнцн бшверю" ме гюонкмемн'||CrLf;
        IS_NUM_DEDUCT_WRONG_ := 1;
      ELS*/
      REC_DETAIL.DEDUCTION := NVL(REC_DETAIL.DEDUCTION, 0);
      if IS_NUMBER(REC_DETAIL.DEDUCTION) = 0 then
        ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "янцкюяхе мю опхлемемхе мюкнцнбнцн бшверю" яндепфхр межхтпнбше яхлбнкш'||CrLf;
        ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "янцкюяхе мю опхлемемхе мюкнцнбнцн бшверю" яндепфхр межхтпнбше яхлбнкш'||CrLf;
        IS_NUM_DEDUCT_WRONG_ := 2;
      end if;

      -- опнбепйю пегхдемярбю
      if REC_DETAIL.RESIDENCE IS NULL then
        ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "пегхдемярбн" ме гюонкмемн'||CrLf;
        ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "пегхдемярбн" ме гюонкмемн'||CrLf;
        IS_NUM_RESIDENCE_WRONG_ := 1;
      elsif IS_NUMBER(REC_DETAIL.RESIDENCE) = 0 then
        ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "пегхдемярбн" яндепфхр межхтпнбше яхлбнкш'||CrLf;
        ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "пегхдемярбн" яндепфхр межхтпнбше яхлбнкш'||CrLf;
        IS_NUM_RESIDENCE_WRONG_ := 2;
      end if;

      --25.10.2018 релейнб юю, гюдювю 192926, пегхдемрярбн он тнплюрс рнкэйн 0 хкх 1
      if REC_DETAIL.RESIDENCE NOT IN ('0', '1') then
        ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "пегхдемярбн" яндепфхр межхтпнбше яхлбнкш'||CrLf;
        ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "пегхдемярбн" яндепфхр межхтпнбше яхлбнкш'||CrLf;
        IS_NUM_RESIDENCE_WRONG_ := 2;
      end if;

      -- опнбепйю пецхнмю
      if REC_DETAIL.DISTRICT IS NULL then
        ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "йнд пецхнмю" ме гюонкмемн'||CrLf;
        ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "йнд пецхнмю" ме гюонкмемн'||CrLf;
        IS_NUM_DISTRICT_WRONG_ := 1;
      elsif IS_NUMBER(REC_DETAIL.DISTRICT) = 0 then
        ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "йнд пецхнмю" яндепфхр межхтпнбше яхлбнкш'||CrLf;
        ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "йнд пецхнмю" яндепфхр межхтпнбше яхлбнкш'||CrLf;
        IS_NUM_DISTRICT_WRONG_ := 2;
      elsif LENGTH(REC_DETAIL.DISTRICT) > 2 then
        ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "йнд пецхнмю" анкэье 2-у яхлбнкнб'||CrLf;
        ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "йнд пецхнмю" анкэье 2-у яхлбнкнб'||CrLf;
        IS_NUM_DISTRICT_WRONG_ := 3;
      end if;

      --06.05.2020:  люлернб яепхй гюдювю http://enpf24.kz/company/personal/user/3215/tasks/task/view/512143/
      --еякх б тюике сйюгюкх леяъж мювюкю бшокюрш, рн опнбепхл мю йнппейрмнярэ ее гюонкмемхъ
      if NVL(IS_WORK_FIRST_MONTH_FILE_PENS_, 0) = 1 then
        if REC_DETAIL.FIRSTMONTH IS NULL then
          ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "леяъж мювюкю бшокюрш" ме гюонкмемн'||CrLf;
          ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "леяъж мювюкю бшокюрш" ме гюонкмемн'||CrLf;
          IS_FIRSTMONTH_WRONG_ := 1;
        elsif IS_NUMBER(REC_DETAIL.FIRSTMONTH) = 0 then
          ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "леяъж мювюкю бшокюрш" яндепфхр межхтпнбше яхлбнкш'||CrLf;
          ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "леяъж мювюкю бшокюрш" яндепфхр межхтпнбше яхлбнкш'||CrLf;
          IS_FIRSTMONTH_WRONG_ := 2;
        elsif LENGTH(REC_DETAIL.FIRSTMONTH) > 2 then
          ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "леяъж мювюкю бшокюрш" анкэье 2-у яхлбнкнб'||CrLf;
          ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "леяъж мювюкю бшокюрш" анкэье 2-у яхлбнкнб'||CrLf;
          IS_FIRSTMONTH_WRONG_ := 3;
        elsif TO_NUMBER(REC_DETAIL.FIRSTMONTH) < 1 OR TO_NUMBER(REC_DETAIL.FIRSTMONTH) > 12 then
          ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. гмювемхе онкъ "леяъж мювюкю бшокюрш" днкфем ашрэ б дхюоюгнме нр 1 дн 12'||CrLf;
          ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. гмювемхе онкъ "леяъж мювюкю бшокюрш" днкфем ашрэ б дхюоюгнме нр 1 дн 12'||CrLf;
          IS_FIRSTMONTH_WRONG_ := 4;

        -- 04.02.2021  люлернб яепхй он гюдюве б ахрпхйяе 591156 "бМЕЯЕМХЕ ХГЛЕМЕМХИ Б ОПНБЕПЙХ ОН ЛЕЯЪЖС ОЕПБНИ БШОКЮРШ ОПХ НАПЮАНРЙЕ ТЮИКНБ PENS"
        -- яг руюб-5887 НР 03.02.2021, О.7.2 оПХ ОНКСВЕМХХ ТНПЛЮРЮ PENS САПЮРЭ ОПНБЕПЙС, ЕЯКХ ЛЕЯЪЖ ОЕПБНИ БШОКЮРШ ПЮБЕМ ЛЕЯЪЖС ОНДЮВХ ГЮЪБКЕМХЪ цй.
        /*elsif TO_NUMBER(REC_DETAIL.FIRSTMONTH) = TO_NUMBER(To_Char(APPLYDATEGK_, 'MM')) then
          ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. гмювемхе онкъ "леяъж оепбни бшокюрш" пюбем леяъжс ондювх гюъбкемхъ'||CrLf;
          ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. гмювемхе онкъ "леяъж оепбни бшокюрш" пюбем леяъжс ондювх гюъбкемхъ'||CrLf;
          IS_FIRSTMONTH_WRONG_ := 5;*/
        else
-- 10.12.2024  аШВЙНБ          я СВЕРНЛ ГЮОНГДЮКНИ НРОПЮБЙХ Й МЮЛ ХГ цй ГЮЪБКЕМХИ ОН нямя,
--                              ОЕПЕЯРЮКЮ ПЮАНРЮРЭ МЮЬЮ КНЦХЙЮ ЙНМРПНКЪ ЙНППЕЙРМНЯРХ ОНКЪ FirstMonth МЮ ЯРШЙЕ КЕР
--                              оНЩРНЛС ЯРЮПСЧ КНЦХЙС Ъ ЛЕМЪЧ
--    Ю РНВМЕЕ НРЙКЧВЮЧ ОПНБЕПЙС ГЮ МЕМЮДНАМНЯРЭЧ
/*
          DECLARE
            APPLYDATEGK_MONTH_  NUMBER := TO_NUMBER(To_Char(APPLYDATEGK_, 'MM'));
            APPLYDATEGK_DATE_   DATE   := TRUNC(APPLYDATEGK_,'MM');
            FIRSTMONTH_MONTH_   NUMBER := TO_NUMBER(REC_DETAIL.FIRSTMONTH);
            FIRSTMONTH_DATE_    DATE   := To_Date('01.'||REC_DETAIL.FIRSTMONTH||'.'||To_Char(APPLYDATEGK_, 'YYYY'));
          begin
            if APPLYDATEGK_MONTH_ = 11 then
              if FIRSTMONTH_MONTH_ IN (1, 12) then
                FIRSTMONTH_DATE_ := APPLYDATEGK_DATE_;
              else
                FIRSTMONTH_DATE_ := To_Date('01.01.9999', 'DD.MM.YYYY');
              end if;
            elsif APPLYDATEGK_MONTH_ = 12 then
              if FIRSTMONTH_MONTH_ IN (1, 2) then
                FIRSTMONTH_DATE_ := APPLYDATEGK_DATE_;
              else
                FIRSTMONTH_DATE_ := To_Date('01.01.9999', 'DD.MM.YYYY');
              end if;
            elsif MONTHS_BETWEEN(FIRSTMONTH_DATE_, APPLYDATEGK_DATE_) < 0 then
              ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. гмювемхе онкъ "леяъж оепбни бшокюрш" лемэье, вел леяъж ондювх гюъбкемхъ'||CrLf;
              ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. гмювемхе онкъ "леяъж оепбни бшокюрш" лемэье, вел леяъж ондювх гюъбкемхъ'||CrLf;
              IS_FIRSTMONTH_WRONG_ := 6;
            end if;

            -- 30.11.2020:  люлернб яепхй он гюдюве б ахрпхйяе 562499 сапюк опнбепйс он йнллемрс анрс
            -- http://enpf24.kz/workgroups/group/40/tasks/task/view/562499/index.php?MID=684828#com684828
          --  if MONTHS_BETWEEN(FIRSTMONTH_DATE_, APPLYDATEGK_DATE_) > 2 then
          --    ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. гмювемхе онкъ "леяъж оепбни бшокюрш" анкэье, вел анкее 2-у леяъжеб я леяъжю ондювх гюъбкемхъ'||CrLf;
          --    ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. гмювемхе онкъ "леяъж оепбни бшокюрш" анкэье, вел анкее 2-у леяъжеб я леяъжю ондювх гюъбкемхъ'||CrLf;
          --    IS_FIRSTMONTH_WRONG_ := 7;
          --  end if;
          end;
*/
          NULL;
        end if;
      end if;

      -- 06.05.2020  люлернб яепхй гюдювю http://enpf24.kz/company/personal/user/3215/tasks/task/view/512143/
      -- опнбепйю дюммшу н кэцнре
      /*for PRIVIL IN (select PRV.RIGHT_CODE, -- йЮРЕЦНПХЪ ОНКСВЮРЕКЪ, ХЛЕЧЫЕЦН ОПЮБН МЮ ОПХЛЕМЕМХЕ ЯРЮМДЮПРМНЦН МЮКНЦНБНЦН БШВЕРЮ
                            PRV.DATE_from, -- дЮРЮ БНГМХЙМНБЕМХЪ ОПЮБЮ МЮ ОПХЛЕМЕМХЕ ЯРЮМДЮПРМНЦН БШВЕРЮ
                            PRV.DATE_TO,
                            PRV.KIDS -- яПНЙ ДЕИЯРБХЪ ОПЮБЮ МЮ ОПХЛЕМЕМХЕ ЯРЮМДЮПРМНЦН МЮКНЦНБНЦН БШВЕРЮ
                  from XMLTABLE(XMLNAMESPACES(DEFAULT ''),
                      '//privilege' PASSING XMLType(REC_DETAIL.PRIVILEGES)
                      COLUMNS RIGHT_CODE  VARCHAR2(2)  path 'rightCode',
                              DATE_from   VARCHAR2(30) path 'datefrom',
                              DATE_TO     VARCHAR2(30) path 'dateTo',
                              KIDS        XMLTYPE       path 'kids'
                               ) PRV
                    )
      loop*/
      for PRIVIL IN (select PRV.RIGHT_CODE, -- йЮРЕЦНПХЪ ОНКСВЮРЕКЪ, ХЛЕЧЫЕЦН ОПЮБН МЮ ОПХЛЕМЕМХЕ ЯРЮМДЮПРМНЦН МЮКНЦНБНЦН БШВЕРЮ
                            PRV.DATE_from, -- дЮРЮ БНГМХЙМНБЕМХЪ ОПЮБЮ МЮ ОПХЛЕМЕМХЕ ЯРЮМДЮПРМНЦН БШВЕРЮ
                            PRV.DATE_TO,
                            PRV.KIDS -- яПНЙ ДЕИЯРБХЪ ОПЮБЮ МЮ ОПХЛЕМЕМХЕ ЯРЮМДЮПРМНЦН МЮКНЦНБНЦН БШВЕРЮ
                  from XMLTABLE(XMLNAMESPACES(DEFAULT ''),
                      '//privilege' PASSING XMLType(BODY_FILE_)
                      COLUMNS RIGHT_CODE  VARCHAR2(2)  path 'rightCode',
                              DATE_from   VARCHAR2(30) path 'datefrom',
                              DATE_TO     VARCHAR2(30) path 'dateTo',
                              KIDS        XMLTYPE      path 'kids'
                               ) PRV
                    ) loop
        if IS_NUMBER(PRIVIL.RIGHT_CODE) = 0 then
          ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "йюрецнпхъ онксвюрекъ, хлечыецн опюбн мю опхлемемхе ярюмдюпрмнцн мюкнцнбнцн бшверю" яндепфхр межхтпнбше яхлбнкш'||CrLf;
          ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "йюрецнпхъ онксвюрекъ, хлечыецн опюбн мю опхлемемхе ярюмдюпрмнцн мюкнцнбнцн бшверю" яндепфхр межхтпнбше яхлбнкш'||CrLf;
          IS_NUM_DEDUCT_WRONG_ := 1;
        end if;

        if PRIVIL.RIGHT_CODE IS NOT NULL and PRIVIL.DATE_from IS NULL then
          ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. сйюгюмю йюрецнпхъ кэцнрш, мн дюрю бнгмхймнбемхъ опюбю мю опхлемемхе ярюмдюпрмнцн мюкнцнбнцн бшверю ме сйюгюмю'||CrLf;
          ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. сйюгюмю йюрецнпхъ кэцнрш, мн дюрю бнгмхймнбемхъ опюбю мю опхлемемхе ярюмдюпрмнцн мюкнцнбнцн бшверю ме сйюгюмю'||CrLf;
          IS_PRIVILEGES_WRONG_ := 2;
        end if;

        if PRIVIL.DATE_from IS NOT NULL then
          begin
            DATE_from_PRIVILEGE_ := To_Date(SUBSTR(PRIVIL.DATE_from,1,10), 'YYYY-MM-DD');
          exception
            when others then
              begin
                DATE_from_PRIVILEGE_ := To_Date(SUBSTR(PRIVIL.DATE_from,1,10), 'DD.MM.YYYY');
              exception
                when others then
                  ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю бнгмхймнбемхъ опюбю мю опхлемемхе ярюмдюпрмнцн мюкнцнбнцн бшверю" мейнппейрмн'||CrLf;
                  ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю бнгмхймнбемхъ опюбю мю опхлемемхе ярюмдюпрмнцн мюкнцнбнцн бшверю" мейнппейрмн'||CrLf;
                  IS_PRIVILEGES_WRONG_ := 3;
              end;
          end;
        end if;

        if TRIM(PRIVIL.DATE_TO) IS NOT NULL then
          begin
            DATE_TO_PRIVILEGE_ := To_Date(SUBSTR(PRIVIL.DATE_TO,1,10), 'YYYY-MM-DD');
          exception
            when others then
              begin
                DATE_TO_PRIVILEGE_ := To_Date(SUBSTR(PRIVIL.DATE_TO,1,10), 'DD.MM.YYYY');
              exception
                when others then
                  ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю бнгмхймнбемхъ опюбю мю опхлемемхе ярюмдюпрмнцн мюкнцнбнцн бшверю" мейнппейрмн'||CrLf;
                  ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю бнгмхймнбемхъ опюбю мю опхлемемхе ярюмдюпрмнцн мюкнцнбнцн бшверю" мейнппейрмн'||CrLf;
                  IS_PRIVILEGES_WRONG_ := 4;
              end;
          end;
        end if;

        if TO_NUMBER(PRIVIL.RIGHT_CODE) IN (5, 6, 7, 8) then
          select COUNT(1)
          into CNT_
          from XMLTABLE(XMLNAMESPACES(DEFAULT ''),
                   '//child' PASSING PRIVIL.KIDS
          COLUMNS IIN VARCHAR2(12)  path 'IIN') KID;

          if CNT_ = 0 then
            ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "дкъ онксвюрекеи я йюрецнпхълх (RIGHTCODE) 5, 6, 7, 8" ме сйюгюм пюгдек ябедемхъ н пеа╗мйе/хмбюкхде'||CrLf;
            ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "дкъ онксвюрекеи я йюрецнпхълх (RIGHTCODE) 5, 6, 7, 8" ме сйюгюм пюгдек ябедемхъ н пеа╗мйе/хмбюкхде'||CrLf;
            IS_PRIVILEGES_KIDS_WRONG_ := 1;
          end if;
        end if;

        for KIDS IN (select KID.IIN,
                            KID.SURNAME,
                            KID.NAME,
                            KID.PATRONYMIC,
                            KID.BIRTHDATE,
                            KID.DEGREE,
                            KID.INVALIDITYbeginDATE,
                            KID.INVALIDITYENDDATE,
                            KID.DOC_BASE,
                            KID.NUM_TRANS_ADOPTIVE_FAMILY,
                            KID.DATE_TRANS_ADOPTIVE_FAMILY,
                            KID.DATE_END_TRANS_ADOPTIVE_FAMILY
                       from XMLTABLE(XMLNAMESPACES(DEFAULT ''),
                              '//child' PASSING PRIVIL.KIDS
                      COLUMNS IIN                             VARCHAR2(12) path 'IIN',
                              SURNAME                         VARCHAR2(30) path 'surname',
                              NAME                            VARCHAR2(30) path 'name',
                              PATRONYMIC                      VARCHAR2(30) path 'patronymic',
                              BIRTHDATE                       VARCHAR2(30) path 'birthDate',
                              DEGREE                          VARCHAR2(1)  path 'invalidity/degree',
                              INVALIDITYbeginDATE             VARCHAR2(30) path 'invalidity/invaliditybeginDate',
                              INVALIDITYENDDATE               VARCHAR2(30) path 'invalidity/invalidityEndDate',
                              DOC_BASE                        VARCHAR2(2)  path 'document/type',
                              NUM_TRANS_ADOPTIVE_FAMILY       VARCHAR2(30) path 'document/number',
                              DATE_TRANS_ADOPTIVE_FAMILY      VARCHAR2(30) path 'document/date',
                              DATE_END_TRANS_ADOPTIVE_FAMILY  VARCHAR2(30) path 'document/endDate'
                               ) KID
                    ) loop
          if KIDS.IIN IS NULL then
            ERRMSG := 'мюпсьем тнплюр яннаыемхъ PENS. онке ххм пеа╗мйю/хмбюкхдю ме гюонкмемн'||CrLf;
            ERRMSGGK := 'мюпсьем тнплюр яннаыемхъ PENS. онке ххм пеа╗мйю/хмбюкхдю ме гюонкмемн'||CrLf;
            IS_PRIVILEGES_KIDS_WRONG_ := 2;
          elsif LENGTH(KIDS.IIN) <> 12 then
            ERRMSG := 'мюпсьем тнплюр яннаыемхъ PENS. онке ххм пеа╗мйю/хмбюкхдю днкфмн ашрэ 12 яхлбнкнб'||CrLf;
            ERRMSGGK := 'мюпсьем тнплюр яннаыемхъ PENS. онке ххм пеа╗мйю/хмбюкхдю днкфмн ашрэ 12 яхлбнкнб'||CrLf;
            IS_PRIVILEGES_KIDS_WRONG_ := 3;
          elsif IS_NUMBER(KIDS.IIN) = 0 then
            ERRMSG := 'мюпсьем тнплюр яннаыемхъ PENS. онке ххм пеа╗мйю/хмбюкхдю яндепфхр ме жхтпнбше яхлбнкш'||CrLf;
            ERRMSGGK := 'мюпсьем тнплюр яннаыемхъ PENS. онке ххм пеа╗мйю/хмбюкхдю яндепфхр ме жхтпнбше яхлбнкш'||CrLf;
            IS_PRIVILEGES_KIDS_WRONG_ := 4;
          end if;

          if KIDS.SURNAME IS NULL and KIDS.NAME IS NULL and KIDS.PATRONYMIC IS NULL then
            ERRMSG := 'мюпсьем тнплюр яннаыемхъ PENS. ндмн хг онке тхн пеа╗мйю/хмбюкхдю наъгюрекэмн дкъ гюонкмемхъ'||CrLf;
            ERRMSGGK := 'мюпсьем тнплюр яннаыемхъ PENS. ндмн хг онке тхн пеа╗мйю/хмбюкхдю наъгюрекэмн дкъ гюонкмемхъ'||CrLf;
            IS_PRIVILEGES_KIDS_WRONG_ := 5;
          end if;

          if KIDS.BIRTHDATE IS NULL then
            ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю пнфдемхъ пеа╗мйю/хмбюкхдю" ме гюонкмемн'||CrLf;
            ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю пнфдемхъ пеа╗мйю/хмбюкхдю" ме гюонкмемн'||CrLf;
            IS_PRIVILEGES_KIDS_WRONG_ := 6;
          else
            begin
              DT_KIDS_ := To_Date(SUBSTR(KIDS.BIRTHDATE,1,10), 'YYYY-MM-DD');
            exception
              when others then
                begin
                  DT_KIDS_ := To_Date(SUBSTR(KIDS.BIRTHDATE,1,10), 'DD.MM.YYYY');
                exception
                  when others then
                    ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю пнфдемхъ пеа╗мйю/хмбюкхдю" мейнппейрмн'||CrLf;
                    ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю пнфдемхъ пеа╗мйю/хмбюкхдю" мейнппейрмн'||CrLf;
                    IS_PRIVILEGES_KIDS_WRONG_ := 7;
                end;
            end;
          end if;

          if TO_NUMBER(PRIVIL.RIGHT_CODE) IN (5, 6) then
            if IS_NUMBER(KIDS.DEGREE) = 0 then
              ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "йюрецнпхъ/цпсоою хмбюкхдмнярх" яндепфхр межхтпнбше яхлбнкш'||CrLf;
              ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "йюрецнпхъ/цпсоою хмбюкхдмнярх" яндепфхр межхтпнбше яхлбнкш'||CrLf;
              IS_PRIVILEGES_KIDS_WRONG_ := 6;
            end if;

            if TRIM(KIDS.INVALIDITYbeginDATE) IS NULL then
              ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю сярюмнбкемхъ хмбюкхдмнярх пеа╗мйю/хмбюкхдю" ме гюонкмемн'||CrLf;
              ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю сярюмнбкемхъ хмбюкхдмнярх пеа╗мйю/хмбюкхдю" ме гюонкмемн'||CrLf;
              IS_PRIVILEGES_KIDS_WRONG_ := 6;
            else
              begin
                INVALIDITYbeginDATE_ := To_Date(SUBSTR(KIDS.INVALIDITYbeginDATE,1,10), 'YYYY-MM-DD');
              exception
                when others then
                  begin
                    INVALIDITYbeginDATE_ := To_Date(SUBSTR(KIDS.INVALIDITYbeginDATE,1,10), 'DD.MM.YYYY');
                  exception
                    when others then
                      ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю сярюмнбкемхъ хмбюкхдмнярх пеа╗мйю/хмбюкхдю" мейнппейрмн'||CrLf;
                      ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю сярюмнбкемхъ хмбюкхдмнярх пеа╗мйю/хмбюкхдю" мейнппейрмн'||CrLf;
                      IS_PRIVILEGES_KIDS_WRONG_ := 7;
                  end;
              end;
            end if;

            if TRIM(KIDS.INVALIDITYENDDATE) IS NOT NULL then
              begin
                INVALIDITYENDDATE_ := To_Date(SUBSTR(KIDS.INVALIDITYENDDATE,1,10), 'YYYY-MM-DD');
              exception
                when others then
                  begin
                    INVALIDITYENDDATE_ := To_Date(SUBSTR(KIDS.INVALIDITYENDDATE,1,10), 'DD.MM.YYYY');
                  exception
                    when others then
                      ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "япнй деиярбхъ хмбюкхдмнярх" мейнппейрмн'||CrLf;
                      ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "япнй деиярбхъ хмбюкхдмнярх" мейнппейрмн'||CrLf;
                      IS_PRIVILEGES_KIDS_WRONG_ := 8;
                  end;
              end;
            end if;

            if IS_NUMBER(KIDS.DOC_BASE) = 0 then
              ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "рхо днйслемрю" яндепфхр межхтпнбше яхлбнкш'||CrLf;
              ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "рхо днйслемрю" яндепфхр межхтпнбше яхлбнкш'||CrLf;
              IS_PRIVILEGES_KIDS_WRONG_ := 9;
            end if;

            if KIDS.NUM_TRANS_ADOPTIVE_FAMILY IS NULL then
              ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "рхо днйслемрю" ме гюонкмемн'||CrLf;
              ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "рхо днйслемрю" ме гюонкмемн'||CrLf;
              IS_PRIVILEGES_KIDS_WRONG_ := 10;
            end if;

            if TRIM(KIDS.DATE_TRANS_ADOPTIVE_FAMILY) IS NULL then
              ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю днйслемрю" ме гюонкмемн'||CrLf;
              ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю днйслемрю" ме гюонкмемн'||CrLf;
              IS_PRIVILEGES_KIDS_WRONG_ := 11;
            else
              begin
                DATE_TRANS_ADOPTIVE_FM_ := To_Date(SUBSTR(KIDS.DATE_TRANS_ADOPTIVE_FAMILY,1,10), 'YYYY-MM-DD');
              exception
                when others then
                  begin
                    DATE_TRANS_ADOPTIVE_FM_ := To_Date(SUBSTR(KIDS.DATE_TRANS_ADOPTIVE_FAMILY,1,10), 'DD.MM.YYYY');
                  exception
                    when others then
                      ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю днйслемрю" мейнппейрмн'||CrLf;
                      ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "дюрю днйслемрю" мейнппейрмн'||CrLf;
                      IS_PRIVILEGES_KIDS_WRONG_ := 12;
                  end;
              end;
            end if;

            if TRIM(KIDS.DATE_END_TRANS_ADOPTIVE_FAMILY) IS NOT NULL then
              begin
                DATE_END_TRANS_ADOPTIVE_FM_ := To_Date(SUBSTR(KIDS.DATE_END_TRANS_ADOPTIVE_FAMILY,1,10), 'YYYY-MM-DD');
              exception
                when others then
                  begin
                    DATE_END_TRANS_ADOPTIVE_FM_ := To_Date(SUBSTR(KIDS.DATE_END_TRANS_ADOPTIVE_FAMILY,1,10), 'DD.MM.YYYY');
                  exception
                    when others then
                      ERRMSG := ERRMSG||'мюпсьем тнплюр яннаыемхъ PENS. онке "япнй деиярбхъ" мейнппейрмн'||CrLf;
                      ERRMSGGK := ERRMSGGK||'мюпсьем тнплюр яннаыемхъ PENS. онке "япнй деиярбхъ" мейнппейрмн'||CrLf;
                      IS_PRIVILEGES_KIDS_WRONG_ := 13;
                  end;
              end;
            end if;
          end if;
        end loop;  --- for KIDS IN (select KID.IIN,
      end loop; --- for PRIVIL IN (select PRV.RIGHT_CODE

      if (IS_NUM_FIO_WRONG_ + IS_DATE_DT_WRONG_ + IS_DATE_APPLYDATEGK_WRONG_ + IS_NUM_IIN_WRONG_ +
          IS_NUM_POL_WRONG_ + IS_NUM_QUEUE_WRONG_ + IS_NUM_DEDUCT_WRONG_ + IS_NUM_RESIDENCE_WRONG_ +
          IS_NUM_DISTRICT_WRONG_ + IS_MOBPHONE_WRONG_ + IS_HOMEPHONE_WRONG_ + IS_APPLYNUMBERGK_WRONG_ +
          IS_iMETHOD_WRONG_ + IS_PRIVILEGES_WRONG_ + IS_PRIVILEGES_KIDS_WRONG_ + IS_FIRSTMONTH_WRONG_ +
          IS_paymentsType_WRONG_ + IS_includeOPV_WRONG_) > 0 then -- 15.12.2023
        ERRCODE := 3;
        PROC_SIGN_ := 3;
        GOTO INS_DETAILS;
      end if;


      IIN_ := REC_DETAIL.IIN;

      BLOCK_ := '05 - онхяй гюопняю жнм';

      P_PENS_GET_IN_ZON(REC_DETAIL.IIN,            -- хыс гюопня жнм
                        P_INGOING_PARSED_ZON_,
                        ERRCODE,
                        ERRMSG);
      /*if ERRCODE <> 0 then
        PROC_SIGN_ := 3;
        GOTO INS_DETAILS;
      end if; */

      -- опнбепъеряъ б ад хюхя яннаыемхе PENS C рюйхл фе мнлепнл гюъбкемхъ мю бшокюрс цй (щкелемр APPLYNUMBERGK б яннаыемхх PENS).
      -- еякх яннаыемхе мюидемн я кчашл ярюрсянл напюанрйх гю хяйкчвемхел ярюрсянб ╚ме напюанрюм╩ х ╚ньхайю опх напюанрйе гюопняю╩
      BLOCK_ := '06 - онхяй яннаыемхъ PENS я рел фе мнлепнл';
      select COUNT(*)
        into CNT_
        from P_INGOING_PARSED_PENS PP
       where PP.APPLYNUMBERGK = REC_DETAIL.APPLYNUMBERGK
         and PP.PROCEED_SIGN NOT IN (0, -1, 3);
      if CNT_ > 0 then
        PROC_SIGN_ := 3;
        ERRCODE := 3;
        ERRMSG := 'онбрнпмне яннаыемхе';
        ERRMSGGK := 'онбрнпмне яннаыемхе';
        GOTO INS_DETAILS;
      end if;

      -- еякх б яннаыемхх PENS б онке "янцкюяхе мю опхлемемхе опюбн мю бшвер опх мюкнцннакнфемхх он оемяхнммшл бшокюрюл"
      -- сйюгюмн дпсцне гмювемхе вел "1" - рн дюммни гюохях менаундхлн опхябнхрэ ярюрся "нрпхжюрекэмши нрбер"
      -- 10.12.2018 релейнб юю, гюдювю 273413, реоепэ б REC_DETAIL.DEDUCTION гмювемхъ нр 2 дн 9
      -- 20.12.2018 релейнб юю, гюдювю 273413, яберкюмю яйюгюкю сапюрэ бннаые опнбепйс http://enpf24.kz/extranet/contacts/personal/log/336047/?commentId=301640#com301640
      /*if REC_DETAIL.DEDUCTION = 0 then
        PROC_SIGN_ := 3;
        ERRCODE := 3;
        ERRMSG := 'б гюъбкемхх наъгюрекэмн днкфмн ашрэ бшярюбкемн янцкюяхе бйкюдвхйю мю опхлемемхе опюбю мю бшвер опх мюкнцннакнфемхх он оемяхнммшл бшокюрюл';
        ERRMSGGK := 'б гюъбкемхх наъгюрекэмн днкфмн ашрэ бшярюбкемн янцкюяхе бйкюдвхйю мю опхлемемхе опюбю мю бшвер опх мюкнцннакнфемхх он оемяхнммшл бшокюрюл';
        GOTO INS_DETAILS;
      end if; */

      -- опнбепйх он осмйрюл 2-9
      BLOCK_ := '07 - гюосяй опнбепнй он осмйрюл 2-9';
      PROC_SIGN_ := 0;
      -- 03.06.2020 йЕКДЕЬЕБ ю.ю. нВХЯРХЛ БПЕЛЕММСЧ РЮАКХЖС
      -- http://enpf24.kz/company/personal/user/3316/tasks/task/view/514116/
      DELETE from P_CLAIM_PO_COMMENT#;

      P_PENS_CHECKS_FOR_LOAD(0,    --MODE_
                             REC_DETAIL.IIN,       --IDN_ => :IDN_,
                             REC_DETAIL.FM,
                             REC_DETAIL.NM,
                             DT_,
                             REC_DETAIL.SEX,       -- 01.04.2019 релейнб юю, гюдювю 326287, онк опнбепърэ рнфе
                             REC_DETAIL.PAYMENTSTYPE,  -- 15.12.2023 аШВЙНБ  дНАЮБКЪЕЛ НАПЮАНРЙС ГЮЪБКЕМХИ ОН нямя
                             case when REC_DETAIL.PAYMENTSTYPE=3 then REC_DETAIL.INCLUDEOPV else 1 end,    -- 15.12.2023 аШВЙНБ  дНАЮБКЪЕЛ НАПЮАНРЙС ГЮЪБКЕМХИ ОН нямя
                             G_PERSON_,
                             ERRMSGARR,
                             P_CONTRACTARR_,
                             ERRCODE,
                             ERRMSG);
      if ERRCODE <> 0 then
        PROC_SIGN_ := -1;
        GOTO INS_DETAILS;
      end if;

      DECLARE
        K  INTEGER := 0;
      begin
        for I IN 0..ERRMSGARR.COUNT-1 loop
          if ERRMSGARR(I).ERRCODE = 3 then
            PROC_SIGN_ := 3;
            GOTO INS_DETAILS;
          else
            WARNMSGARR(K).ERRCODE := ERRMSGARR(I).ERRCODE;
            WARNMSGARR(K).ERRMSGENPF := ERRMSGARR(I).ERRMSGENPF;
            K := K + 1;
          end if;
        end loop;
      end;
      ----------------------------------------------------------------------------------------------
      -- нопедекч дюрш гюъбкемхъ
      -- 1) дюрю опхелю гюъбкемхъ нопедекхрэ он якедсчыелс опхмжхос, еякх мю дюрс гюъбкемхъ цй
      -- (нмю аеперяъ хг яннаыемхъ PENS) бйкюдвхй ме днярхц оемяхнммнцн бнгпюярю, рн дюрю опхелю гюъбкемхъ
      -- пюбмю дюре днярхфемхъ бйкюдвхйнл оемяхнммнцн бнгпюярю, хмюве пюбмю дюре гюъбкемхъ цй
      -- 2) "дюрю янярюбкемхъ гюъбк-ъ" онлеыюеряъ гмювемхе онкъ дюрю гюъбкемхъ цй хг яннаыемхъ PENS
      -- 3) дюрю пецхярпюжхх б тнмде  онлеыюрэ рейсысч йюкемдюпмсч дюрс яепбепю
      -- йюйсч дюрс х онк апюрэ??? онйю бгък мюьх
      ----------------------------------------------------------------------------------------------
      DECLARE
        AGE_      NUMBER;
--        PensDT_   Date;   -- дЮРЮ ДНЯРХФЕМХЪ ОЕМЯХНММНЦН БНГПЮЯРЮ
      begin
        select *
          into G_PERSON_REC
          from G_NAT_PERSON GNP
         where GNP.G_PERSON = G_PERSON_;

        -- 15.12.2023  аШВЙНБ  оПНБЕПХЛ МЮКХВХЕ 84 OPPV Х БНГПЮЯР ДКЪ БШОКЮР ОН нямя
        BLOCK_ := '07.1 - опнбепйю мюкхвхъ 84 нооб';
        if REC_DETAIL.PAYMENTSTYPE = 3 THEN
          SELECT CASE WHEN COUNT(DISTINCT MT.PERIOD) >= 84 THEN 1
                        ELSE 0 END
            INTO HAS84OPPV_
            FROM MAIN.P_CONTRACT PC
            JOIN MAIN.P_OPR OP ON OP.P_CONTRACT = PC.P_CONTRACT
            JOIN MAIN.P_G_OPRKND OK ON OK.P_G_OPRKND = OP.P_G_OPRKND AND OK.P_G_GROUP_OPRKND = 3
            JOIN MAIN.P_LT_I_OPR_MT102 LT ON LT.P_OPR = OP.P_OPR
            JOIN MAIN.I_MT102 MT ON MT.I_MT102 = LT.I_MT102
           WHERE PC.G_PERSON_RECIPIENT = G_PERSON_
             AND PC.P_G_CONTRACT_KND = 18;
          IF HAS84OPPV_ != 1 THEN
            PROC_SIGN_ := 3;
            ERRCODE := 3;
            ERRMSG   := 'с бйкюдвхйю нрясрярбсер 84 леяъжю скюрш нооб, бшокюрш мебнглнфмш';
            ERRMSGGK := 'с бйкюдвхйю нрясрярбсер 84 леяъжю скюрш нооб, бшокюрш мебнглнфмш';
            GOTO INS_DETAILS;
          END IF;
          if ADD_MONTHS(G_PERSON_REC.DT, 12*55) > sysdate THEN
            PROC_SIGN_ := 3;
            ERRCODE := 3;
            ERRMSG   := 'бйкюдвхй ме днярхц 55-кермецн бнгпюярю, бшокюрш мебнглнфмш';
            ERRMSGGK := 'бйкюдвхй ме днярхц 55-кермецн бнгпюярю, бшокюрш мебнглнфмш';
            GOTO INS_DETAILS;
          END IF;
        END IF;

        BLOCK_ := '07.2 - опнбепйю бнгпюярю';

        -- ДНАЮБКЕМН 30.01.2020 ДКЪ КЕВЕМХЪ ЙНЯЪЙНБ цй, ЙНРНПШЕ МЕ НРОПЮБХКХ БЯБНЕБПЕЛЕММН Б 2019 ЦНДС
        --  ГЮЪБКЕМХЪ ФЕМЫХМ, НАПЮРХБЬХУЯЪ Б ДЕЙЮАПЕ 2019.
        --  ю РЕОЕПЭ ХУ МСФМН ОПХМЪРЭ Б ЪМБЮПЕ 2020, ЙНЦДЮ БНГПЮЯР МЕ СДНБКЕРБНПХРЕКЭМШИ.
        --  яОХЯНЙ ЩРХУ ФЕМЫХМ МЮОПЮБКЕМ Б емот НТХЖХЮКЭМШЛ ОХЯЭЛНЛ ХГ цй, НМХ ДНАЮБКЕМШ Б РЮАКХЖС P_exception_PENS
        begin
          select E.P_exception_PENS, E.APPLYDATEGK
            into P_exception_PENS_, EXC_APPLYDATEGK_
            from MAIN.P_exception_PENS E
           where E.IDN = G_PERSON_REC.IDN
             and E.IS_ACTIVE = 1
             and E.DATE_TO > SYSDATE;
        exception
          when others then NULL;
        end;
        -- APPLYDATEGK_ := NVL(EXC_APPLYDATEGK_, APPLYDATEGK_); -- МЕ ДЕКЮЕЛ ЩРНЦН, ВРНАШ ГЮТХЙЯХПНБЮРЭ БЕГДЕ ПЕЮКЭМШЕ ДЮММШЕ,
                                                                --  МН DATE_RECEPTION МХФЕ НОПЕДЕКЪЕРЯЪ Я СВЕРНЛ ХЯЙКЧВЕМХИ
        -- ХЯОПЮБКЕМН аШВЙНБШЛ л. 30.01.2020
        -- нАМНБКЕММЮЪ КНЦХЙЮ НОПЕДЕКЕМХЪ ДЮРШ янярюбкемхъ гюъбк-ъ
        -- нОПЕДЕКЪЕЛ ДЮРС ДНЯРХФЕМХЪ ОЕМЯХНММНЦН БНГПЮЯРЮ ЩРХЛ БЙКЮДВХЙНЛ
        /*PensDT_ := ADD_MONTHS(G_PERSON_REC.DT,
                     12 * CASE -- ГДЕЯЭ Б ГЮБХЯХЛНЯРХ НР ОНКЮ Х ЦНДЮ ПНФДЕМХЪ НОПЕДЕКЪЕРЯЪ БНГПЮЯР ДНЯРХФЕМХЪ ОЕМЯХХ
                            when G_PERSON_REC.G_SEX = 2 then 63
                            when EXTRACT(YEAR from G_PERSON_REC.DT)>=1965 then 63
                            when EXTRACT(YEAR from G_PERSON_REC.DT)<=1959 then 58
                              else  CASE EXTRACT(YEAR from G_PERSON_REC.DT)
                                when 1960 then CASE when EXTRACT(MONTH from G_PERSON_REC.DT)<=6 then 58.5
                                                                                                else  59 end
                                when 1961 then CASE when EXTRACT(MONTH from G_PERSON_REC.DT)<=6 then 59.5
                                                                                                else  60 end
                                when 1962 then CASE when EXTRACT(MONTH from G_PERSON_REC.DT)<=6 then 60.5
                                                                                                else  61 end
                                when 1963 then CASE when EXTRACT(MONTH from G_PERSON_REC.DT)<=6 then 61.5
                                                                                                else  62 end
                                when 1964 then CASE when EXTRACT(MONTH from G_PERSON_REC.DT)<=6 then 62.5
                                                                                                else  63 end end end);
                          -- ЛНФМН ОПЕДШДСЫХЕ 11 ЯРПНЙ ГЮЛЕМХРЭ МЮ НДМС:
                          --  else  (EXTRACT(YEAR from G_PERSON_REC.DT) - 1901.5) + TRUNC(EXTRACT(MONTH from G_PERSON_REC.DT)/7)/2 end);
        DATE_RECEPTION_ := GREATEST(PensDT_, NVL(EXC_APPLYDATEGK_, APPLYDATEGK_));
        */
        DATE_PAPER_ := NVL(EXC_APPLYDATEGK_, APPLYDATEGK_);
        -- яРЮПЮЪ КНЦХЙЮ (ДН 30.01.2020)

        -- 27.05.2020 люлернб я.ю. бепмск мюгюд кнцхйс бшвхякемхъ дюрш днярхфемхъ оемя бнупюярю, йнрнпюъ ашкю яйнпперхпнбюммю 31.01.2019 ашвйнб л.
        -- нопедекъч оемяхнммши бнгпюяр
        if REC_DETAIL.PAYMENTSTYPE = 3 then
          AGE_ := 55;
        elsif G_PERSON_REC.G_SEX = 2 then
          AGE_ := 63;
        else
          CASE
            when To_Char(DATE_PAPER_, 'YYYY') < '2018' then AGE_ := 58;
            when To_Char(DATE_PAPER_, 'YYYY') = '2018' then AGE_ := 58.5;
            when To_Char(DATE_PAPER_, 'YYYY') = '2019' then AGE_ := 59;
            when To_Char(DATE_PAPER_, 'YYYY') = '2020' then AGE_ := 59.5;
            when To_Char(DATE_PAPER_, 'YYYY') = '2021' then AGE_ := 60;
            when To_Char(DATE_PAPER_, 'YYYY') = '2022' then AGE_ := 60.5;
            when To_Char(DATE_PAPER_, 'YYYY') = '2023' then AGE_ := 61;
            when To_Char(DATE_PAPER_, 'YYYY') = '2024' then AGE_ := 61;
            when To_Char(DATE_PAPER_, 'YYYY') = '2025' then AGE_ := 61;
            when To_Char(DATE_PAPER_, 'YYYY') = '2026' then AGE_ := 61;
            when To_Char(DATE_PAPER_, 'YYYY') = '2027' then AGE_ := 61;
            when To_Char(DATE_PAPER_, 'YYYY') = '2028' then AGE_ := 61.5;
            when To_Char(DATE_PAPER_, 'YYYY') = '2029' then AGE_ := 62;
            when To_Char(DATE_PAPER_, 'YYYY') = '2030' then AGE_ := 62.5;
                                                       else AGE_ := 63;
          end CASE;
        end if;

        -- дюрс днярхфемхъ оемяхнммнцн бнгпюярю нопедекхк рюй - дп + 63 цнд
        if (MONTHS_BETWEEN(APPLYDATEGK_, G_PERSON_REC.DT)) / 12 < AGE_ and REC_DETAIL.PAYMENTSTYPE = 1 then
          DATE_RECEPTION_ := ADD_MONTHS(G_PERSON_REC.DT, 12 * AGE_);
        else
          DATE_RECEPTION_ := APPLYDATEGK_;
        end if;

        -- 21.05.2021  люлернб яепхй яецндмъ он рекетнмнлс пюгцнбнпс я люйяхлнл ашвйнбшл, рхлспнл уюлхрнбшл х цскэлхпни йхлнкюебни
        -- ашкн пеьемн бмеярх хглемемхъ б ноепедекемхе дюрш опхелю гюъбкемхъ дкъ гюъбкемхх я опхгмюйнл опнюйрхбмюъ сяксцю он бйкюдвхйюл
        -- с йнрнпшу оепбюъ дюрю днярхфемхъ оемяхнммнцн бнгпюярю сфе мюярсохкю (сфе мюярсохкю он дюммшл цй APPLYDATEGK_)
        if REC_DETAIL.IMETHOD IN (2, 4) and REC_DETAIL.PAYMENTSTYPE = 1 then
--          select ADD_MONTHS(G_PERSON_REC.DT, 12 * CASE when G_PERSON_REC.G_SEX = 2 then 63
--                                    when EXTRACT(YEAR from G_PERSON_REC.DT)>=1965 then 63
--                                    when EXTRACT(YEAR from G_PERSON_REC.DT)<=1959 then 58
--                               else  (EXTRACT(YEAR from G_PERSON_REC.DT) - 1901.5) + TRUNC(EXTRACT(MONTH from G_PERSON_REC.DT)/7)/2 end)
---
          select ADD_MONTHS(G_PERSON_REC.DT, 12 * CASE when G_PERSON_REC.G_SEX = 2 then 63
                                     when EXTRACT(YEAR from G_PERSON_REC.DT)<=1959 then 58
                                     when EXTRACT(YEAR from G_PERSON_REC.DT)>=1969 then 63
                                     else
                                       case EXTRACT(YEAR from G_PERSON_REC.DT)*100 + trunc(EXTRACT(month from G_PERSON_REC.DT)/7)
                                         when 196000 then 58.5
                                         when 196001 then 59
                                         when 196100 then 59.5
                                         when 196101 then 60
                                         when 196200 then 60.5
                                         when 196700 then 61.5
                                         when 196701 then 62
                                         when 196800 then 62.5
                                         when 196801 then 63
                                                     else 61 end end)
---
            into FIRST_DAY_PENS_AGE_
            from DUAL;

          if FIRST_DAY_PENS_AGE_ <= APPLYDATEGK_ then
            DATE_RECEPTION_ := APPLYDATEGK_;
          end if;
        end if;

        --DATE_PAPER_ := APPLYDATEGK_;

        DATE_REGISTR_  := SYSDATE;
      end;

      ----------------------------------------------------------------------------------------------
      -- нашвмше опнбепйх опх бярюбйе гюъбкемхъ
      BLOCK_ := '08 - гюосяй нашвмшу опнбепнй';
      for I IN 0..P_CONTRACTARR_.COUNT - 1 loop
        --25.10.2018 релейнб юю, гюдювю 192926, гюъбкемхе мюдн янгдюбюрэ рнкэйн мю рнл днцнбнпе, мю йнрнпнл мер деиярбсчыецн гюъбкемхъ
        select COUNT(*)
        into CNT_
        from P_CLAIM_PAY_OUT PP
          join P_G_PAY_OUT_SUB_TYPE PST on PST.P_G_PAY_OUT_SUB_TYPE = PP.P_G_PAY_OUT_SUB_TYPE
        where PP.P_CONTRACT = P_CONTRACTARR_(I)
          and PP.P_G_CLAIM_STATUS NOT IN (-7, -2, -3)
          and PST.P_G_PAY_OUT_TYPE IN (2, 8, 9)
          and PP.P_G_CLAIM_PAY_OUT_KND <> 4
          and PP.IS_ACTIVE = 1
          -- 04.09.2025 аШВЙНБ  рЕОЕПЭ АСДЕЛ ОПХМХЛЮРЭ ГЮЪБКЕМХЪ ОН БНГПЮЯРС ОПХ МЮКХВХХ МЕГЮЙПШРНЦН ГЮЪБКЕМХЪ ОН нямя Б ЯБЪГХ Я ХГЛЕМЕМХЪЛХ Б оПЮБХКЮУ ╧521
          and (REC_DETAIL.PAYMENTSTYPE != 1 or pp.p_g_pay_out_sub_type not in (600,601,602,603));

        if CNT_ > 0 then
          CONTINUE;
        end if;

        select DECODE(REC_DETAIL.PAYMENTSTYPE,
                       1, DECODE(PC.P_G_CONTRACT_KND, 
                          18, 539, 
                          11, 1001,
                          402),     -- БШОКЮРЮ ОН БНГПЮЯРС (15.12.2023)
                       3, DECODE(PC.P_G_CONTRACT_KND, 18, 602, 600))     -- БШОКЮРЮ ОН нямя
        into P_G_PAY_OUT_SUB_TYPE_
        from P_CONTRACT PC
        where PC.P_CONTRACT = P_CONTRACTARR_(I);

        vlcLogStep := ' P_CHECK_PAY_CLAIM_PARAMS'
                     ||' P_CONTRACTARR_(I)['||P_CONTRACTARR_(I)||']'
                     ||' G_PERSON_['||G_PERSON_||']'
                     ||' P_G_PAY_OUT_SUB_TYPE_['||P_G_PAY_OUT_SUB_TYPE_||']'      -- P_G_PAY_OUT_SUB_TYPE||']'
                     ||' DATE_PAPER_['||DATE_PAPER_||']'
                     ||' DATE_RECEPTION_['||DATE_RECEPTION_||']'
                     ||' DATE_REGISTR_['||DATE_REGISTR_||']'              --CLAIMREC.DATE_REGISTR||']'
                     ||' FM['||G_PERSON_REC.FM||']'
                     ||' NM['||G_PERSON_REC.NM||']'
                     ||' FT['||G_PERSON_REC.FT||']'
                     ||' DT['||G_PERSON_REC.DT||']'
                     ||' RNN['||G_PERSON_REC.RNN||']'                --RNN||']'
                     ||' IDN['||G_PERSON_REC.IDN||']'
                     ||' IS_REPUBLIC_SITIZEN['||G_PERSON_REC.IS_REPUBLIC_SITIZEN||']'
                     ||' G_COUNTRY['||G_PERSON_REC.G_COUNTRY||']'
                     ||' G_SEX['||G_PERSON_REC.G_SEX||']'
                     ||' MOBILEPHONE['||REC_DETAIL.MOBILEPHONE||']'
                     ||' EMAIL['||REC_DETAIL.EMAIL||']'
                     ||' HOMEPHONE['||REC_DETAIL.HOMEPHONE||']'
                     ||' G_ID_KIND['||G_PERSON_REC.G_ID_KIND||']'
                     ||' ID_SERIAL['||G_PERSON_REC.ID_SERIAL||']'
                     ||' ID_NUM['||G_PERSON_REC.ID_NUM||']'
                     ||' ID_DATE['||G_PERSON_REC.ID_DATE||']'
                     ||' ID_ISSUER['||G_PERSON_REC.ID_ISSUER||']'
                     ||' PRIVILEGE_DATE_begin_['||PRIVILEGE_DATE_begin_||']'
                     ||' FIRSTMONTH(I)['||REC_DETAIL.FIRSTMONTH||']';

        P_CHECK_PAY_CLAIM_PARAMS(NULL,--CLAIMREC.P_CLAIM_PAY_OUT,
                                 P_CONTRACTARR_(I),
                                 G_PERSON_,
                                 1,                          -- P_G_CLAIM_PAY_OUT_KND,
                                 P_G_PAY_OUT_SUB_TYPE_,      -- P_G_PAY_OUT_SUB_TYPE,
                                 4,                          -- G_TYPE_PERIOD,
                                 4,                          -- P_G_REGISTRATION_TYPE,  -- вепег цй
                                 7,                          -- P_G_REGISTRATION_PLACE, онйю онярюбкч вепег хмер - меонмърмн врн ярюбхрэ
                                 0,                          -- IS_SEND_MAIL,
                                 DATE_PAPER_,
                                 DATE_RECEPTION_,
                                 DATE_REGISTR_,              --CLAIMREC.DATE_REGISTR,
                                 NULL,                       --HERITAGE_PERCENT_FORMAL,
                                 NULL,                       --HERITAGE_PERCENT_REAL,
                                 NULL,                       --HERITAGE_QUANTITY,
                                 0,                          --PRIVILEGE_IS_HAVE,
                                 NULL,                --PRIVILEGE_DATE_END,
                                 NULL,                --P_G_ANALYTICTYPES,
                                 NULL,                --P_G_ANALYTICCODES,
                                 NULL,                --CLAIMREC.BANK_G_JUR_PERSON,
                                 NULL,                --CLAIMREC.G_JUR_PERSON_ACC,
                                 0,                --CLAIMREC.BANK_IS_FOREIGN,
                                 0,                --CLAIMREC.BANK_BY_POST,
                                 0,                --CLAIMREC.BANK_IS_CARD_ACCOUNT,
                                 NULL,                --CLAIMREC.BANK_BIK,
                                 NULL,                --CLAIMREC.BANK_RNN,
                                 NULL,                --CLAIMREC.BANK_ACCOUNT,
                                 NULL,                --CLAIMREC.BANK_ACCOUNT_PERSONAL,
                                 2,                --CLAIMREC.BANK_IS_RECIPIENT_ACCOUNT,
                                 NULL,                --.BANK_BRANCH_NAME,
                                 NULL,                --REC.BANK_BRANCH_CODE,
                                 NULL,                --.BANK_FOREIGN_KPP,
                                 NULL,                --.BANK_FOREIGN_ACCOUNT,
                                 NULL,                --.BANK_NAME,
                                 4,                --.G_CURRENCY,
                                 NULL,                --.P_G_TRUSTEE,
                                 NULL,                --.WARRANT_NUMBER,
                                 NULL,                --.WARRANT_begin_DATE,
                                 NULL,                --.WARRANT_END_DATE,
                                 G_PERSON_REC.FM,
                                 G_PERSON_REC.NM,
                                 G_PERSON_REC.FT,
                                 G_PERSON_REC.DT,
                                 G_PERSON_REC.RNN,                --RNN,
                                 G_PERSON_REC.IDN,
                                 G_PERSON_REC.IS_REPUBLIC_SITIZEN,
                                 G_PERSON_REC.G_COUNTRY,
                                 G_PERSON_REC.G_SEX,
                                 NULL,              --G_PERSON_REC.ADDRESS,
                                 REC_DETAIL.MOBILEPHONE,
                                 REC_DETAIL.EMAIL,
                                 REC_DETAIL.HOMEPHONE,
                                 G_PERSON_REC.G_ID_KIND,
                                 G_PERSON_REC.ID_SERIAL,
                                 G_PERSON_REC.ID_NUM,
                                 G_PERSON_REC.ID_DATE,
                                 G_PERSON_REC.ID_ISSUER,
                                 0,                     --IS_INCOMPETENT,
                                 0,                          --CLAIMREC.HERITAGE_IS_PERCENT_CORRECT,
                                 NULL,                --.FMTRUSTEE,
                                 NULL,                --.NMTRUSTEE,
                                 NULL,                --.FTTRUSTEE,
                                 NULL,                --.DTTRUSTEE,
                                 NULL,                --.ADDRESSTRUSTEE,
                                 NULL,                --.G_ID_KINDTRUSTEE,
                                 NULL,                --.ID_SERIALTRUSTEE,
                                 NULL,                --.ID_NUMTRUSTEE,
                                 NULL,                --.ID_DATETRUSTEE,
                                 NULL,                --.ID_ISSUERTRUSTEE,
                                 NULL,                --.RNNTRUSTEE,
                                 NULL,                --.IDNTRUSTEE,
                                 NULL,                --.G_RESIDENTS_TRUSTEE,
                                 NULL,                --.IS_TRUSTEE_PREDSTAVITEL,
                                 NULL,                --.TRUSTOSNOVAINE,
                                 -- дюммше днбепхрекъ
                                 NULL,                --.FMSETTLOR,
                                 NULL,                --.NMSETTLOR,
                                 NULL,                --.FTSETTLOR,
                                 NULL,                --.DTSETTLOR,
                                 NULL,                --.G_ID_KINDSETTLOR ,
                                 NULL,                --.ID_SERIALSETTLOR,
                                 NULL,                --.ID_NUMSETTLOR,
                                 NULL,                --.ID_DATESETTLOR,
                                 NULL,                --.ID_ISSUERSETTLOR,
                                 NULL,                --.RNNSETTLOR,
                                 NULL,                --.IDNSETTLOR,
                                 NULL,                --.G_RESIDENTS_SETTLOR,
                                 null,                --.AddressSettlor
                                 NULL,                --.BANK_INTERMED_NAME,
                                 NULL,                --.BANK_INTERMED_SWIFT,
                                 NULL,                --.BANK_INTERMED_ACC,
                                 --
                                 NULL,                --.FMJURPREDSTAVITEL,
                                 NULL,                --.NMJURPREDSTAVITEL,
                                 NULL,                --.FTJURPREDSTAVITEL,
                                 NULL,                --.IDDOCPREDSTAVITEL,
                                 NULL,                --.DOCNUMPREDSTAVITEL,
                                 NULL,                --.DOCDATEPREDSTAVITEL,
                                 NULL,                --.APPJURPREDSTAVITEL,
                                 -- мнбше онкъ хг гюъбйх ╧2, осмйр 1, релейнб ю.ю. 19.04.2016
                                 NULL,                --.CARDNUM,
                                 NULL,                --.SORTCODE,
                                 NULL,                --.BANK_COUNTRY,
                                 NULL,                --.FM_LAT,
                                 NULL,                --.NM_LAT,
                                 NULL,                --.FT_LAT,
                                 NULL,                --.NO_FT,
                                 NULL,                --.NO_FT2,
                                 --
                                 0,                --.IS_HAVE_RIGHT_REG_OLD_LAW,  -- 30.11.2017 релейнб юю, гюдювю 98809
                                 0,                --.AMOUNT,
                                 0,                --.AMOUNT_IS_MANUAL,
                                 NULL,            -- P_INGOING_PARSED_P01_
                                 NULL,            -- IDN_CHILD_
                                 NULL,  --STR1_
                                 NULL,  --STR2_
                                 1,     --NUMBER1_
                                 3,   --NUMBER2_
                                 G_PERSON_,
                                 NULL,
                                 NULL,
                                 NULL,  --ID_DATE_END_
                                 NULL,  --ID_DATETRUSTEE_END_,
                                 NULL,  --ID_DATESETTLOR_END_,
                                 NULL,  --P_LT_GBDFL_PERSON_DEP_
                                 NULL,  --P_LT_GBDFL_PERSON_REC_
                                 NULL,  --P_LT_GBDFL_PERSON_TRUSTEE_
                                 NULL,  --P_LT_GBDFL_PERSON_SETTLOR_
                                 PRIVILEGE_DATE_begin_,
                                 TO_NUMBER(REC_DETAIL.FIRSTMONTH),
                                 NULL, -- P_G_RELATION_DEGREE
                                 NULL, -- IS_HAVE_RELATION_DEGREE
                                 IS_CHECK_RELATION_DEGREE_,
                                 ERRMSGARRяREGULAR,
                                 ERRMSGARRяREGULAROUR,
                                 WARNMSGARRяREGULAR,
                                 ERRCODE,
                                 ERRMSG,
                                 Warn_CODE,
                                 Warn_MSG);
        if ERRCODE <> 0 then
          PROC_SIGN_ := -1;
          main.pp_Save_ERROR('p_Parse_Insert_Pens[Error P_CHECK_PAY_CLAIM_PARAMS] ['||vlcLogs||'] ['||vlcLogStep||'] ');
          GOTO INS_DETAILS;
        end if;

        -- мЮДН ЯВХРЮРЭ ЯЙНКЭЙН НРПХЖЮРЕКЭМШУ НРБЕРНБ, ЕЯКХ НРПХЖЮРЕКЭМШУ НРБЕРНБ ЯРНКЭЙН ФЕ, ЯЙНКЭЙН Х ЙНМРПЮЙРНБ, РН ЯРЮБХРЯЪ НРПХЖЮРЕКЭМШИ НРБЕР
        if ERRMSGARRяREGULAR.COUNT > 0 then
          NEGATIVEMSGCNT_ := NEGATIVEMSGCNT_ + 1;

        -- еякх еярэ унрэ ндмю ньхайю мюью, рн ярюбкч опхгмюй PROC_SIGN = -1
        elsif ERRMSGARRяREGULAROUR.COUNT > 0 then
          PROC_SIGN_ := -1;
          GOTO INS_DETAILS;

        -- еякх еярэ унрэ ндмю опедсопефдючыюъ ньхайю, рн ярюбкч опхгмюй PROC_SIGN = 2 - онкнфхрекэмши нрбер, мн я онлерйюлх
        elsif WARNMSGARRяREGULAR.COUNT > 0 then
          PROC_SIGN_ := 2;
        else
          PROC_SIGN_ := 1;
        end if;
      end loop;        --- for I IN 0..P_CONTRACTARR_.COUNT - 1 loop

      -- еякх йнкхвеярбн ньхайю "нрпхжюрекэмши нрбер" = йнкхвеярбс йнмрпюйрнб, рн ярюбкч опхгмюй PROC_SIGN = 3 - нрпхжюрекэмши нрбер
      if NEGATIVEMSGCNT_ = P_CONTRACTARR_.COUNT then
        PROC_SIGN_ := 3;
      end if;
      -- йнмеж акнйю пецскъпмше опнбепйх
      ----------------------------------------------------------------------------------------------

      -- бярюбйю гюъбкемхъ х дерюкеи
      <<INS_DETAILS>>

      BLOCK_ := '09 - янгдюмхе гюъбкемхъ';
      -- еякх бяе мнплюкэмн ньханй ме ашкн, хкх ньхайх опедсопефдючыхе, рн бярюбкъч гюъбкемхе
      if ERRCODE = 0 and PROC_SIGN_ IN (1, 2) then --ERRMSGARR.COUNT = 0 and ERRMSGARRяREGULAR.COUNT = 0 and ERRMSGARRяREGULAROUR.COUNT = 0 then
        if REC_DETAIL.RESIDENCE = '1' then
          G_RESIDENTS_ := 1;
          G_COUNTRY_   := 1;
        else
          G_RESIDENTS_ := 2;
          G_COUNTRY_   := NULL;
        end if;

        --мнлеп лна. рекетнмю мювхмюеряъ я "+7", ецн мюдн лемърэ мю "8"
        if REC_DETAIL.MOBILEPHONE IS NULL then
          MOBPHONERASS_ := '80000000000';
        elsif INSTR(REC_DETAIL.MOBILEPHONE, '+7') > 0 then
          MOBPHONERASS_ := REPLACE(REC_DETAIL.MOBILEPHONE, '+7', '8');
        else
          MOBPHONERASS_ := REC_DETAIL.MOBILEPHONE;
        end if;

        -- 10.12.2018 релейнб юю, гюдювю 273413, 4.  ОПХ МЮКХВХХ Б ОНКЕ 13 ГЮОПНЯНБ PENS РХОЮ "4-хМБЮКХДШ I, II, III ЦПСОО" НЯСЫЕЯРБКЪРЭ
        -- Б ЮБРНЛЮРХВЕЯЙНЛ ПЕФХЛЕ xml-ГЮОПНЯ Б жадх Н МЮКХВХХ ХМБЮКХДМНЯРХ (ТНПЛЮР P00), xml-НРБЕР МЮ ЙНРНПШИ (ТНПЛЮР P02)
        -- МЕНАУНДХЛН ОПХЙПЕОХРЭ Б ЮБРНЛЮРХВЕЯЙНЛ ПЕФХЛЕ Б ЯНГДЮБЮЕЛНЕ МЮ НЯМНБЮМХХ ГЮОПНЯЮ PENS ГЮЪБКЕМХЕ МЮ БШОКЮРС (ГЮЙКЮДЙЮ "яОХЯНЙ КЭЦНРМШУ ДНЙСЛЕМРНБ")
        if REC_DETAIL.DEDUCTION = 5 then
          DECLARE
            BLOB_                      BLOB;
            K_ATTACHED_DOC_            K_ATTACHED_DOC#.K_ATTACHED_DOC%TYPE;
            FILE_NAME_                 VARCHAR(15);
            C                          INTEGER := WARNMSGARR.COUNT;
          begin
            ERRCODE := 0;
            ANSWER_WASNT_SUCCESS_ := 0;

            MAIN.P_CLAIM_SEND_P00(G_NAT_PERSON_ => G_PERSON_,
                                  IDN_ => REC_DETAIL.IIN,
                                  P_CLAIM_PAY_OUT_ => NULL,
                                  P_INGOING_PARSED_P01_ => P_INGOING_PARSED_P01_,
                                  DISABILITY_ => DISABILITY_,
                                  DISABILITY_VALIDITY_DATE_ => DISABILITY_VALIDITY_DATE_,
                                  BLOB_ => BLOB_,
                                  ERR_CODE => ERRCODE,
                                  ERR_MSG => ERRMSG
                                  ,DO_COMMIT_ => 0);

            -- еякх ньхайю опнхгнькю, рн бяе пюбмн опнднкфюрэ, опнярн бшбедс, врн ньхайю ашкю
            if ERRCODE <> 0 then
              WARNMSGARR(C).ERRCODE := ERRCODE;
              WARNMSGARR(C).ERRMSGENPF := ERRMSG;
              ANSWER_WASNT_SUCCESS_ := 1;
            end if;

            -- еякх бяе мнплюкэмн, рн мюдн опхйпеохрэ нрбер б гюъбкемхе
            if P_INGOING_PARSED_P01_ IS NOT NULL then
                select SUBSTR(lower(SYS_GUID()), 1, 10)||'.PDF'
                  into FILE_NAME_
                  from DUAL;

                K_INS_ATTACHED_DOC#(G_ATTACHED_DOC_TYPE_ => 551,
                                    ATTACHED_DOC_OBJECT_ => 1008,
                                    DOC_DATE_ => DISABILITY_VALIDITY_DATE_,
                                    DOC_NUM_ => NULL,
                                    FILE_NAME_ => FILE_NAME_,
                                    FILE_EXT_ => 'PDF',
                                    NOTE_ => NULL,
                                    BODY_ => BLOB_,
                                    G_FORM_ATTACHED_DOC_ => 4,
                                    K_ATTACHED_DOC_ => K_ATTACHED_DOC_,
                                    ERR_CODE => ERRCODE,
                                    ERR_MSG => ERRMSG);
                -- еякх ньхайю опнхгнькю, рн бяе пюбмн опнднкфюрэ, опнярн бшбедс, врн ньхайю ашкю
                if ERRCODE <> 0 then
                  C := WARNMSGARR.COUNT;
                  WARNMSGARR(C).ERRCODE := ERRCODE;
                  WARNMSGARR(C).ERRMSGENPF := ERRMSG;
                end if;
            else
              ANSWER_WASNT_SUCCESS_ := 1;
            end if;
          end;
        end if;

        BLOCK_ := '10 - бярюбйю дерюкеи P_INGOING_PARSED_PENS';
        insert into MAIN.P_INGOING_PARSED_PENS(
               P_INGOING_PARSED_PENS,            -- 1
               IIN,                              -- 2
               FM,                               -- 4
               NM,                               -- 5
               FT,                               -- 6
               DT,                               -- 7
               SEX,                              -- 8
               MOBILEPHONE,
               HOMEPHONE,
               EMAIL,
               APPLYNUMBERGK ,                   -- 10
               APPLYDATEGK ,                     -- 11
               QUEUE ,                           -- 12
               DEDUCTION,                        -- 14
               RESIDENCE,                        -- 15
               DISTRICT ,                        -- 16
               PROCEED_SIGN,
               P_INGOING_PARSED_ZON,
               P_INGOING_XML,
               P_CONTRACT_OPV,
               P_CLAIM_PAY_OUT_OPV,
               P_CONTRACT_OPPV,
               P_CLALIM_PAY_OUT_OPPV,            -- 22
               P_CONTRACT_DPV,
               P_CLAIM_PAY_OUT_DPV,
             , PAYMENTSTYPE    -- 15.12.2023
             , INCLUDEOPV
             , G_PERSON
             , ERR_CODE
             , ERR_MSG)
        values(SEQ_P_INGOING_PARSED_PENS.NEXTVAL,   -- 1
               SUBSTR(REC_DETAIL.IIN, 1, 12),       -- 2
               REC_DETAIL.FM,                       -- 4
               REC_DETAIL.NM,                       -- 5
               REC_DETAIL.FT,                       -- 6
               DECODE(IS_DATE_DT_WRONG_, 2, NULL, DT_),                                 -- 7
               DECODE(IS_NUM_POL_WRONG_, 2, NULL, REC_DETAIL.SEX),                      -- 8
               SUBSTR(REC_DETAIL.MOBILEPHONE, 1, 12),
               SUBSTR(REC_DETAIL.HOMEPHONE, 1, 12),
               REC_DETAIL.EMAIL,
               REC_DETAIL.APPLYNUMBERGK,
               DECODE(IS_DATE_APPLYDATEGK_WRONG_, 2, NULL, APPLYDATEGK_),
               DECODE(IS_NUM_QUEUE_WRONG_, 2, NULL, REC_DETAIL.QUEUE),
               DECODE(IS_NUM_DEDUCT_WRONG_, 2, NULL, REC_DETAIL.DEDUCTION),             -- 14
               DECODE(IS_NUM_RESIDENCE_WRONG_, 2, NULL, REC_DETAIL.RESIDENCE),             -- 15
               DECODE(IS_NUM_DISTRICT_WRONG_, 2, NULL, REC_DETAIL.DISTRICT),             -- 16
               PROC_SIGN_,
               P_INGOING_PARSED_ZON_,
               P_INGOING_XML_,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
             , DECODE(IS_PAYMENTSTYPE_WRONG_, 2, NULL, REC_DETAIL.PAYMENTSTYPE)
             , DECODE(IS_includeOPV_WRONG_, 2, NULL, REC_DETAIL.INCLUDEOPV)
             , G_PERSON_
             , ERRCODE
             , SUBSTR(ERRMSG,1,1023))
        return
          P_INGOING_PARSED_PENS
        into
          P_INGOING_PARSED_PENS_;

        for PRIVIL IN (select PRV.RIGHT_CODE, -- йЮРЕЦНПХЪ ОНКСВЮРЕКЪ, ХЛЕЧЫЕЦН ОПЮБН МЮ ОПХЛЕМЕМХЕ ЯРЮМДЮПРМНЦН МЮКНЦНБНЦН БШВЕРЮ
                              PRV.DATE_from, -- дЮРЮ БНГМХЙМНБЕМХЪ ОПЮБЮ МЮ ОПХЛЕМЕМХЕ ЯРЮМДЮПРМНЦН МЮКНЦНБНЦН БШВЕРЮ
                              PRV.DATE_TO,
                              PRV.KIDS -- яПНЙ ДЕИЯРБХЪ ОПЮБЮ МЮ ОПХЛЕМЕМХЕ ЯРЮМДЮПРМНЦН МЮКНЦНБНЦН БШВЕРЮ
                    from XMLTABLE(XMLNAMESPACES(DEFAULT ''),
                        '//privilege' PASSING XMLType(BODY_FILE_/*REC_DETAIL.PRIVILEGES*/)
                        COLUMNS RIGHT_CODE  VARCHAR2(2)  path 'rightCode',
                                DATE_from   VARCHAR2(30) path 'datefrom',
                                DATE_TO     VARCHAR2(30) path 'dateTo',
                                KIDS        XMLTYPE      path 'kids'
                                 ) PRV
                      ) loop

          begin
            DATE_from_PRIVILEGE_ := To_Date(SUBSTR(PRIVIL.DATE_from,1,10), 'YYYY-MM-DD');
          exception
            when others then
              begin
                DATE_from_PRIVILEGE_ := To_Date(SUBSTR(PRIVIL.DATE_from,1,10), 'DD.MM.YYYY');
              exception
                when others then
                  DATE_from_PRIVILEGE_ := SYSDATE;
              end;
          end;

          if TRIM(PRIVIL.DATE_TO) IS NOT NULL then
            begin
              DATE_TO_PRIVILEGE_ := To_Date(SUBSTR(PRIVIL.DATE_TO,1,10), 'YYYY-MM-DD');
            exception
              when others then
                begin
                  DATE_TO_PRIVILEGE_ := To_Date(SUBSTR(PRIVIL.DATE_TO,1,10), 'DD.MM.YYYY');
                exception
                  when others then
                    DATE_TO_PRIVILEGE_ := NULL;
                end;
            end;
          else
            DATE_TO_PRIVILEGE_ := To_Date('31.12.2099', 'DD.MM.YYYY');
          end if;

          insert into MAIN.P_INGOING_PARSED_PENS_PRIVIL
            (P_INGOING_PARSED_PENS_PRIVIL, P_INGOING_PARSED_PENS, RIGHT_CODE, DATE_from, DATE_TO, ERR_CODE, ERR_MSG, SYS_DATE)
          values
            (MAIN.SEQ_P_ING_PARSED_PENS_PRIVIL.NEXTVAL, P_INGOING_PARSED_PENS_, TO_NUMBER(PRIVIL.RIGHT_CODE), DATE_from_PRIVILEGE_, DATE_TO_PRIVILEGE_, NULL, NULL, SYSDATE)
          returning P_INGOING_PARSED_PENS_PRIVIL into P_INGOING_PARSED_PENS_PRIVIL_;

          for KIDS IN (select KID.IIN,
                            KID.SURNAME,
                            KID.NAME,
                            KID.PATRONYMIC,
                            KID.BIRTHDATE,
                            KID.DEGREE,
                            KID.INVALIDITYbeginDATE,
                            KID.INVALIDITYENDDATE,
                            KID.DOC_BASE,
                            KID.NUM_TRANS_ADOPTIVE_FAMILY,
                            KID.DATE_TRANS_ADOPTIVE_FAMILY,
                            KID.DATE_END_TRANS_ADOPTIVE_FAMILY
                       from XMLTABLE(XMLNAMESPACES(DEFAULT ''),
                              '//child' PASSING PRIVIL.KIDS
                      COLUMNS IIN                             VARCHAR2(12) path 'IIN',
                              SURNAME                         VARCHAR2(30) path 'surname',
                              NAME                            VARCHAR2(30) path 'name',
                              PATRONYMIC                      VARCHAR2(30) path 'patronymic',
                              BIRTHDATE                       VARCHAR2(30) path 'birthDate',
                              DEGREE                          VARCHAR2(1)  path 'invalidity/degree',
                              INVALIDITYbeginDATE             VARCHAR2(30) path 'invalidity/invaliditybeginDate',
                              INVALIDITYENDDATE               VARCHAR2(30) path 'invalidity/invalidityEndDate',
                              DOC_BASE                        VARCHAR2(2)  path 'document/type',
                              NUM_TRANS_ADOPTIVE_FAMILY       VARCHAR2(30) path 'document/number',
                              DATE_TRANS_ADOPTIVE_FAMILY      VARCHAR2(30) path 'document/date',
                              DATE_END_TRANS_ADOPTIVE_FAMILY  VARCHAR2(30) path 'document/endDate'
                               ) KID
                      )
          loop

            begin
              DT_KIDS_ := To_Date(SUBSTR(KIDS.BIRTHDATE,1,10), 'YYYY-MM-DD');
            exception
              when others then
                DT_KIDS_ := To_Date(SUBSTR(KIDS.BIRTHDATE,1,10), 'DD.MM.YYYY');
            end;

            begin
              INVALIDITYbeginDATE_ := To_Date(SUBSTR(KIDS.INVALIDITYbeginDATE,1,10), 'YYYY-MM-DD');
            exception
              when others then
                INVALIDITYbeginDATE_ := To_Date(SUBSTR(KIDS.INVALIDITYbeginDATE,1,10), 'DD.MM.YYYY');
            end;

            if TRIM(KIDS.INVALIDITYENDDATE) IS NOT NULL then
              begin
                INVALIDITYENDDATE_ := To_Date(SUBSTR(KIDS.INVALIDITYENDDATE,1,10), 'YYYY-MM-DD');
              exception
                when others then
                  INVALIDITYENDDATE_ := To_Date(SUBSTR(KIDS.INVALIDITYENDDATE,1,10), 'DD.MM.YYYY');
              end;
            else
              INVALIDITYENDDATE_ := To_Date('31.12.2099', 'DD.MM.YYYY');
            end if;

            if KIDS.DATE_TRANS_ADOPTIVE_FAMILY IS NOT NULL then
              begin
                DATE_TRANS_ADOPTIVE_FM_ := To_Date(SUBSTR(KIDS.DATE_TRANS_ADOPTIVE_FAMILY,1,10), 'YYYY-MM-DD');
              exception
                when others then
                  DATE_TRANS_ADOPTIVE_FM_ := To_Date(SUBSTR(KIDS.DATE_TRANS_ADOPTIVE_FAMILY,1,10), 'DD.MM.YYYY');
              end;

              DATE_END_TRANS_ADOPTIVE_FM_ := INVALIDITYbeginDATE_;
            end if;

            insert into MAIN.P_INGOING_PARSED_PENS_KIDS
              (P_INGOING_PARSED_PENS_KIDS,
               P_INGOING_PARSED_PENS_PRIVIL,
               P_INGOING_PARSED_PENS,
               IIN,
               SURNAME,
               NAME,
               PATRONYMIC,
               BIRTHDATE,
               DEGREES,
               INVALIDITYbeginDATE,
               INVALIDITYENDDATE,
               DOC_BASE,
               NUM_TRANS_ADOPTIVE_FAMILY,
               DATE_TRANS_ADOPTIVE_FAMILY,
               DATE_END_TRANS_ADOPTIVE_FAMILY,
               ERR_CODE,
               ERR_MSG,
               SYS_DATE)
            values
              (MAIN.SEQ_P_INGOING_PARSED_PENS_KIDS.NEXTVAL,
               P_INGOING_PARSED_PENS_PRIVIL_,
               P_INGOING_PARSED_PENS_,
               KIDS.IIN,
               KIDS.SURNAME,
               KIDS.NAME,
               KIDS.PATRONYMIC,
               DT_KIDS_,
               KIDS.DEGREE,
               INVALIDITYbeginDATE_,
               INVALIDITYENDDATE_,
               TO_NUMBER(KIDS.DOC_BASE),
               KIDS.NUM_TRANS_ADOPTIVE_FAMILY,
               DATE_TRANS_ADOPTIVE_FM_,
               DATE_END_TRANS_ADOPTIVE_FM_,
               NULL,
               NULL,
               SYSDATE);

            insert into MAIN.P_LT_CLAIM_CHILD_INVALID#(
               P_LT_CLAIM_CHILD_INVALID,
               FM,
               NM,
               FT,
               DT,
               IDN,
               G_PERSON,
               P_CLAIM_PAY_OUT,
               DATE_begin_PRIVILEGE,
               DATE_END_PRIVILEGE,
               DOC_BASE,
               NUM_TRANS_ADOPTIVE_FAMILY,
               DATE_TRANS_ADOPTIVE_FAMILY,
               DATE_END_TRANS_ADOPTIVE_FAMILY,
               COMMENTS,
               SYS_DATE,
               ID_USER)
             values(
               SEQ_P_LT_CLAIM_CHILD_INVALID.NEXTVAL,
               KIDS.SURNAME,
               KIDS.NAME,
               KIDS.PATRONYMIC,
               DT_KIDS_,
               KIDS.IIN,
               NULL,
               NULL,
               INVALIDITYbeginDATE_,
               INVALIDITYENDDATE_,
               DECODE(TO_NUMBER(KIDS.DOC_BASE), 1, 2, 2, 3, 3, 1, 4, 0, TO_NUMBER(KIDS.DOC_BASE)),
               KIDS.NUM_TRANS_ADOPTIVE_FAMILY,
               DATE_TRANS_ADOPTIVE_FM_,
               DECODE(TO_NUMBER(KIDS.DOC_BASE), 4, DATE_END_TRANS_ADOPTIVE_FM_, NULL),
               NULL,
               SYSDATE,
               NVL(CONNECTION_PARAM.IDUSER, 50)
               );
          end loop;
        end loop;

        for I IN 0..P_CONTRACTARR_.COUNT - 1 loop
            --25.10.2018 релейнб юю, гюдювю 192926, гюъбкемхе мюдн янгдюбюрэ рнкэйн мю рнл днцнбнпе, мю йнрнпнл мер деиярбсчыецн гюъбкемхъ
            select COUNT(*)
              into CNT_
              from P_CLAIM_PAY_OUT PP --(!) from P_CLAIM_PAY_OUT$$O PP
             where PP.P_CONTRACT = P_CONTRACTARR_(I)
               and PP.P_G_CLAIM_STATUS NOT IN (-7, -2, -3)
               and (select PST.P_G_PAY_OUT_TYPE from P_G_PAY_OUT_SUB_TYPE PST where PST.P_G_PAY_OUT_SUB_TYPE = PP.P_G_PAY_OUT_SUB_TYPE) IN (2, 8, 9)
               and PP.P_G_CLAIM_PAY_OUT_KND <> 4
               and PP.IS_ACTIVE = 1
               -- 04.09.2025 аШВЙНБ  рЕОЕПЭ АСДЕЛ ОПХМХЛЮРЭ ГЮЪБКЕМХЪ ОН БНГПЮЯРС ОПХ МЮКХВХХ МЕГЮЙПШРНЦН ГЮЪБКЕМХЪ ОН нямя Б ЯБЪГХ Я ХГЛЕМЕМХЪЛХ Б оПЮБХКЮУ ╧521
               and (REC_DETAIL.PAYMENTSTYPE != 1 or pp.p_g_pay_out_sub_type not in (600,601,602,603));

            if CNT_ > 0 then
              CONTINUE;
            end if;

            select DECODE(REC_DETAIL.PAYMENTSTYPE,
                       1, DECODE(PC.P_G_CONTRACT_KND, 
                          18, 539, 
                          11, 1001,
                          402),     -- БШОКЮРЮ ОН БНГПЮЯРС (15.12.2023)
                       3, DECODE(PC.P_G_CONTRACT_KND, 18, 602, 600))     -- БШОКЮРЮ ОН нямя
                 , PC.P_G_CONTRACT_KND
              into P_G_PAY_OUT_SUB_TYPE_,
                   P_G_CONTRACT_KND_
              from P_CONTRACT PC
             where PC.P_CONTRACT = P_CONTRACTARR_(I);

            -- 10.12.2018 релейнб юю, гюдювю 273413, 4.  ОПХ МЮКХВХХ Б ОНКЕ 13 ГЮОПНЯНБ PENS РХОЮ "4-хМБЮКХДШ I, II, III ЦПСОО",
            -- Х НРЯСРЯРБХХ ЮЙРСЮКЭМНЦН НРБЕРЮ МЮ ГЮОПНЯ P00:
            -- 1) ЕЯКХ ЩРН ноб (рд) ДНЦНБНП, РН "402-цПЮТХЙ/ВЮЯРХВМЮЪ БШОКЮРЮ Б ЯБЪГХ Я ДНЯРХФЕМХЕЛ ОЕМЯХНММНЦН БНГПЮЯРЮ";
            -- 2) ЕЯКХ ЩРН нооб ДНЦНБНП, РН "539- цПЮТХЙ/вЮЯРХВМЮЪ БШОКЮРЮ Б ЯБЪГХ Я ДНЯРХФЕМХЕЛ ОЕМЯХНММНЦН БНГПЮЯРЮ нооб";
            -- ЕЯКХ ФЕ НРБЕР ЕЯРЭ Х БН БЯЕ НЯРЮКЭМШУ ЯКСВЮЪУ Б ОНКЕ 13, ЙПНЛЕ 0, РН:
            -- 1) ЕЯКХ ЩРН ноб (рд) ДНЦНБНП "502-цПЮТХЙ/вЮЯРХВМЮЪ БШОКЮРЮ Б ЯБЪГХ Я ДНЯР.ОЕМЯ.БНГПЮЯРЮ/КЭЦНРЮ";
            -- 2) ЕЯКХ ЩРН нооб ДНЦНБНП, РН  "545-цПЮТХЙ/вЮЯРХВМЮЪ БШОКЮРЮ Б ЯБЪГХ Я ДНЯР.ОЕМЯ.БНГПЮЯРЮ/КЭЦНРЮ нооб";
            ------------------------------------------------------ ************-----------------------------------------------------------------------
            -- люлернб яепхй юкхлюлернбхв. йнд мхфе бшдекеммнцн акнйю яксфхк дкъ ябедемхх н кэцнре йюй опедонкнцюкняэ пюмее б оепбшу тнплюрюу налемю
            -- йнцдю б онке DEDUCTION днкфмши ашкх оепедюбюрэ бяе ябедемхъ н кэцнре. мн щрнцн ме ядекюкх х онксвюеряъ б дя 2 х 3 хглемхкх тнплюр
            -- реоепэ янцкюямн мнбнцн тнплюрю ябедекемхъ н кэцнрюу асдер б мнбнл пюгдеке privileges бйкчвюъ х ябедемхъ н деръу хмбюкхдюу рнфе
            if REC_DETAIL.DEDUCTION = 5 and ANSWER_WASNT_SUCCESS_ = 1 then
              if P_G_CONTRACT_KND_ <> 18 then
--                P_G_PAY_OUT_SUB_TYPE_ := 402;
                P_G_PAY_OUT_SUB_TYPE_ := case when REC_DETAIL.PAYMENTSTYPE = 1 then 402
                                              when REC_DETAIL.PAYMENTSTYPE = 3 then 600 end;
              elsif P_G_CONTRACT_KND_ = 11 then 
                P_G_PAY_OUT_SUB_TYPE_ := case when REC_DETAIL.PAYMENTSTYPE = 1 then 1001 end;
--                P_G_PAY_OUT_SUB_TYPE_ = 1001;
              else
--                P_G_PAY_OUT_SUB_TYPE_ := 539;
                P_G_PAY_OUT_SUB_TYPE_ := case when REC_DETAIL.PAYMENTSTYPE = 1 then 539
                                              when REC_DETAIL.PAYMENTSTYPE = 3 then 602 end;
              end if;
            elsif (REC_DETAIL.DEDUCTION = 5 and ANSWER_WASNT_SUCCESS_ = 0) OR (REC_DETAIL.DEDUCTION IN (2, 3, 4, 6, 7, 8, 9)) then
              if P_G_CONTRACT_KND_ <> 18 then
--                P_G_PAY_OUT_SUB_TYPE_ := 502;
                P_G_PAY_OUT_SUB_TYPE_ := case when REC_DETAIL.PAYMENTSTYPE = 1 then 502
                                              when REC_DETAIL.PAYMENTSTYPE = 3 then 601 end;
              elsif P_G_CONTRACT_KND_ = 11 then 
                P_G_PAY_OUT_SUB_TYPE_ := case when REC_DETAIL.PAYMENTSTYPE = 1 then 1001 end;
--                P_G_PAY_OUT_SUB_TYPE_ = 1001;                
              else
--                P_G_PAY_OUT_SUB_TYPE_ := 545;
                P_G_PAY_OUT_SUB_TYPE_ := case when REC_DETAIL.PAYMENTSTYPE = 1 then 545
                                              when REC_DETAIL.PAYMENTSTYPE = 3 then 603 end;
              end if;
              PRIVILEGE_IS_HAVE_  := 1;
              if (REC_DETAIL.DEDUCTION <> 5) OR (REC_DETAIL.DEDUCTION = 5 and DISABILITY_VALIDITY_DATE_ IS NULL) then
                PRIVILEGE_DATE_END_ := To_Date('01.01.9999', 'DD.MM.YYYY');
              else
                PRIVILEGE_DATE_END_ := DISABILITY_VALIDITY_DATE_;
              end if;
              P_G_ANALYTICTYPES_  := 12;

              select DECODE(REC_DETAIL.DEDUCTION,
                            2, 39,
                            3, 108,
                            4, 4175,
                            5, DECODE(DISABILITY_,
                                      '1', 117,
                                      '2', 120,
                                      '3', 123),
                            6, 4177,
                            7, 125,
                            8, 4178,
                            9, 4180)
                into P_G_ANALYTICCODES_
                from DUAL;
            end if;
            ------------------------------------------------------ ************-----------------------------------------------------------------------
            -- 06.05.2020 люлернб я.ю. он гюдюве б ахрпхйяе ╧512143 дя ╧ 2 х дя ╧ 3. онйю мюкхвхе кэцнрш х ецн йюрецнпхч асдс нопедекърэ хг онякедмеи
            -- гюохях б рюакхже MAIN.P_INGOING_PARSED_PENS_PRIVIL, рюй йюй мю рейсыхи лнлемр мю онмърмн йюй нопедекхрэ. мер нохяюмхъ б онярюмнбйе
            -- дюкее мюдн асдер яопняхрэ с люйяхлю йюй бшвхякърэ бяе щрн
            select COUNT(1)
              into CNT_
              from MAIN.P_INGOING_PARSED_PENS_PRIVIL PP
             where PP.P_INGOING_PARSED_PENS = P_INGOING_PARSED_PENS_;

            if CNT_ > 0 then
              if P_G_CONTRACT_KND_ <> 18 then
                P_G_PAY_OUT_SUB_TYPE_ := case when REC_DETAIL.PAYMENTSTYPE = 1 then 502
                                              when REC_DETAIL.PAYMENTSTYPE = 3 then 601 end;
              else
                P_G_PAY_OUT_SUB_TYPE_ := case when REC_DETAIL.PAYMENTSTYPE = 1 then 545
                                              when REC_DETAIL.PAYMENTSTYPE = 3 then 603 end;
              end if;
              PRIVILEGE_IS_HAVE_  := 1;
              P_G_ANALYTICTYPES_  := 12;

              select DECODE(PP.RIGHT_CODE,
                            1, 39,
                            2, 108,
                            3, 4175,
                            4, 123,
                            5, 4177,
                            6, 4181,
                            7, 4178,
                            8, 4180),
                            PP.DATE_from,
                    CASE PP.RIGHT_CODE
                      when 5 then
                         NULL
                      when 6 then
                        NULL
                      when 7 then
                        NULL
                      when 8 then
                        NULL
                      else
                        DECODE(PP.DATE_TO, NULL, To_Date('01.01.9999', 'DD.MM.YYYY'), PP.DATE_TO)
                    end
                into P_G_ANALYTICCODES_, PRIVILEGE_DATE_begin_, PRIVILEGE_DATE_END_
                from MAIN.P_INGOING_PARSED_PENS_PRIVIL PP
               where PP.P_INGOING_PARSED_PENS_PRIVIL IN (select P_INGOING_PARSED_PENS_PRIVIL
                                                           from (select PP.P_INGOING_PARSED_PENS_PRIVIL
                                                                   from MAIN.P_INGOING_PARSED_PENS_PRIVIL PP
                                                                  where PP.P_INGOING_PARSED_PENS = P_INGOING_PARSED_PENS_
                                                                  order by DECODE(PP.DATE_TO, NULL, To_Date('01.01.9999', 'DD.MM.YYYY'), PP.DATE_TO) DESC
                                                                )
                                                          where ROWNUM = 1
                                                        );

            end if;

            P_INS_CLAIM_PAY_OUT(NULL,--CLAIMREC.P_CLAIM_PAY_OUT,
                                 P_CONTRACTARR_(I),
                                 G_PERSON_,
                                 1,                          -- P_G_CLAIM_PAY_OUT_KND,
                                 P_G_PAY_OUT_SUB_TYPE_,      -- P_G_PAY_OUT_SUB_TYPE,
                                 4,                          -- G_TYPE_PERIOD,
                                 4,                          -- P_G_REGISTRATION_TYPE,  -- вепег цй
                                 -- P_G_REGISTRATION_PLACE:
                                 CASE REC_DETAIL.IMETHOD when 1 then 7      -- жнм
                                                         when 2 then 9      -- оПНЮЙРХБ
                                                         when 4 then 9      -- оПНЮЙРХБ
                                                                else  10 end,-- e-gov
                                 0,                          -- IS_SEND_MAIL,
                                 DATE_PAPER_,
                                 DATE_RECEPTION_,
                                 DATE_REGISTR_,              --CLAIMREC.DATE_REGISTR,
                                 NULL,                       --HERITAGE_PERCENT_FORMAL,
                                 NULL,                       --HERITAGE_PERCENT_REAL,
                                 NULL,                       --HERITAGE_QUANTITY,
                                 PRIVILEGE_IS_HAVE_,         --PRIVILEGE_IS_HAVE,
                                 PRIVILEGE_DATE_END_,        --PRIVILEGE_DATE_END,
                                 P_G_ANALYTICTYPES_,         --P_G_ANALYTICTYPES,
                                 P_G_ANALYTICCODES_,         --P_G_ANALYTICCODES,
                                 NULL,                --CLAIMREC.BANK_G_JUR_PERSON,
                                 NULL,                --CLAIMREC.G_JUR_PERSON_ACC,
                                 0,                --CLAIMREC.BANK_IS_FOREIGN,
                                 0,                --CLAIMREC.BANK_BY_POST,
                                 0,                --CLAIMREC.BANK_IS_CARD_ACCOUNT,
                                 NULL,                --CLAIMREC.BANK_BIK,
                                 NULL,                --CLAIMREC.BANK_RNN,
                                 NULL,                --CLAIMREC.BANK_ACCOUNT,
                                 NULL,                --CLAIMREC.BANK_ACCOUNT_PERSONAL,
                                 2,                --CLAIMREC.BANK_IS_RECIPIENT_ACCOUNT,
                                 NULL,                --.BANK_BRANCH_NAME,
                                 NULL,                --REC.BANK_BRANCH_CODE,
                                 NULL,                --.BANK_FOREIGN_KPP,
                                 NULL,                --.BANK_FOREIGN_ACCOUNT,
                                 NULL,                --.BANK_NAME,
                                 4,                --.G_CURRENCY,
                                 NULL,                --.P_G_TRUSTEE,
                                 NULL,                --.WARRANT_NUMBER,
                                 NULL,                --.WARRANT_begin_DATE,
                                 NULL,                --.WARRANT_END_DATE,
                                 G_PERSON_REC.FM,
                                 G_PERSON_REC.NM,
                                 G_PERSON_REC.FT,
                                 G_PERSON_REC.DT,
                                 G_PERSON_REC.RNN,                --RNN,
                                 G_PERSON_REC.IDN,
                                 G_RESIDENTS_,
                                 G_COUNTRY_,                      --G_COUNTRY
                                 G_PERSON_REC.G_SEX,
                                 NULL,              --G_PERSON_REC.ADDRESS,
                                 MOBPHONERASS_,  --MOBILEPHONE,
                                 REC_DETAIL.EMAIL,
                                 NULL,                       --REC_DETAIL.HOMEPHONE,
                                 NULL,                --.G_ID_KIND,
                                 NULL,                --.ID_SERIAL,
                                 NULL,                --.ID_NUM,
                                 NULL,                --.ID_DATE,
                                 NULL,                --.ID_ISSUER,
                                 0,                     --IS_INCOMPETENT,
                                 0,                          --CLAIMREC.HERITAGE_IS_PERCENT_CORRECT
                                 NULL,                --.P_REESTR_KZ_
                                 NULL,                --.FMTRUSTEE,
                                 NULL,                --.NMTRUSTEE,
                                 NULL,                --.FTTRUSTEE,
                                 NULL,                --.DTTRUSTEE,
                                 NULL,                --.ADDRESSTRUSTEE,
                                 NULL,                --.G_ID_KINDTRUSTEE,
                                 NULL,                --.ID_SERIALTRUSTEE,
                                 NULL,                --.ID_NUMTRUSTEE,
                                 NULL,                --.ID_DATETRUSTEE,
                                 NULL,                --.ID_ISSUERTRUSTEE,
                                 NULL,                --.RNNTRUSTEE,
                                 NULL,                --.IDNTRUSTEE,
                                 NULL,                --.FMSETTLOR,
                                 NULL,                --.NMSETTLOR,
                                 NULL,                --.FTSETTLOR,
                                 NULL,                --.DTSETTLOR,
                                 NULL,                --.G_ID_KINDSETTLOR ,
                                 NULL,                --.ID_SERIALSETTLOR,
                                 NULL,                --.ID_NUMSETTLOR,
                                 NULL,                --.ID_DATESETTLOR,
                                 NULL,                --.ID_ISSUERSETTLOR,
                                 NULL,                --.RNNSETTLOR,
                                 NULL,                --.IDNSETTLOR,
                                 null,                --.AddressSettlor
                                 0,                   --IS_PREDSTAVITEL_
                                 NULL,                --.G_RESIDENTS_TRUSTEE
                                 NULL,                --G_RESIDENTS_SETTLOR_
                                 NULL,                --.BANK_INTERMED_NAME,
                                 NULL,                --.BANK_INTERMED_SWIFT,
                                 NULL,                --.BANK_INTERMED_ACC,
                                 NULL,                -- TRUST_OSNOVANIE_
                                 --
                                 NULL,                --.FMJURPREDSTAVITEL,
                                 NULL,                --.NMJURPREDSTAVITEL,
                                 NULL,                --.FTJURPREDSTAVITEL,
                                 NULL,                --.IDDOCPREDSTAVITEL,
                                 NULL,                --.DOCNUMPREDSTAVITEL,
                                 NULL,                --.DOCDATEPREDSTAVITEL,
                                 NULL,                --.APPJURPREDSTAVITEL,
                                 NULL,                --.CARDNUM,
                                 NULL,                --.SORTCODE,
                                 NULL,                --.BANK_COUNTRY,
                                 NULL,                --.FM_LAT,
                                 NULL,                --.NM_LAT,
                                 NULL,                --.FT_LAT,
                                 NULL,                --.NO_FT,
                                 NULL,                --.NO_FT2,
                                 --
                                 0,                --.IS_HAVE_RIGHT_REG_OLD_LAW,  -- 30.11.2017 релейнб юю, гюдювю 98809
                                 0,                --.AMOUNT,
                                 0,                --.AMOUNT_IS_MANUAL,
                                 NULL,            -- P_INGOING_PARSED_P01_
                                 NULL,            -- IDN_CHILD_
                                 ---
                                 ---
                                 1,               --MODE_
                                 REC_DETAIL.APPLYNUMBERGK,
                                 APPLYDATEGK_,
                                 TO_NUMBER(REC_DETAIL.DISTRICT),
                                 TO_NUMBER(REC_DETAIL.QUEUE),
                                 NULL,                          -- мерс б тнплюре PENS  DATE_PAY_RESTART_
                                 REC_DETAIL.HOMEPHONE,
                                 0,                             --PAYS_IS_STOPPED_GK_
                                 NULL,                          --G_REASON_PAY_STOP_GK_
                                 NULL,                          --REASON_PAY_STOP_GK_
                                 0,                             --PAYS_IS_STOPPED_ENPF_
                                 NULL,                          --G_REASON_PAY_STOP_ENPF_
                                 NULL,                          --REASON_PAY_STOP_ENPF_
                                 NULL,                          --G_OFFICIAL_PAY_STOPPED_
                                 TO_NUMBER(REC_DETAIL.DEDUCTION),
                                 P_INGOING_PARSED_PENS_,
                                 NULL,      -- DATE_PAY_STOP_GK_
                                 G_PERSON_,
                                 NULL,
                                 NULL,
                                 NULL,  --ID_DATE_END_
                                 NULL,  --ID_DATETRUSTEE_END_,
                                 NULL,  --ID_DATESETTLOR_END_,
                                 NULL,  --P_LT_GBDFL_PERSON_DEP_
                                 NULL,  --P_LT_GBDFL_PERSON_REC_
                                 NULL,  --P_LT_GBDFL_PERSON_TRUSTEE_
                                 NULL,  --P_LT_GBDFL_PERSON_SETTLOR_
                                 PRIVILEGE_DATE_begin_,
                                 TO_NUMBER(REC_DETAIL.FIRSTMONTH),
                                 NULL, -- P_G_RELATION_DEGREE
                                 NULL, -- IS_HAVE_RELATION_DEGREE
                                 NULL,
                                 0,         -- DO_COMMIT_
                                 P_CLAIM_PAY_OUT_,
                                 ERRCODE,
                                 ERRMSG);      --MODE_
          if ERRCODE <> 0 then
            PROC_SIGN_ := -1;
            EXIT;
          end if;

          --25.09.2023: лХПЕЕБ ю. еЯКХ ГЮЪБКЕМХЕ СЯОЕЬМН ЯНГДЮКНЯЭ, РН Х ЯНГДЮЕЛ ЯНЦКЮЬЕМХЕ МЮ НАПЮАНРЙС ДЮММШУ
          --05.03.2025: лХПЕЕБ ю. ОН ГЮДЮВЕ https://enpf24.kz/company/personal/user/66/tasks/task/view/1177890/index.php?MID=1837864#com1837864
          --гЮЪБЙЮ ╧443. 'дНПЮАНРЙХ ТСМЙЖХНМЮКЮ ОПНЯЛНРПЮ ЯБЕДЕМХИ Н ЯНЦКЮЯХЪУ (ОЕПЯ. ДЮММШЕ) Б ВЮЯРХ ДНАЮБКЕМХЪ ОНКЕИ (ОНБЕПЕММНЕ КХЖН/ГЮЙНММШИ
          --ОПЕДЯРЮБХРЕКЭ, МНЛЕП ГЮЪБКЕМХЪ, БХДЮ ГЮЪБКЕМХЪ)'
          --опх онярсокемхх гюъбкемхъ нр цй б пюлйюу нямя ме гюонкмърэ ябедемхъ н янцкюяхх;
          --дНАЮБХК REC_DETAIL.PAYMENTSTYPE != 3
          if ERRCODE = 0 and P_CLAIM_PAY_OUT_ is not null and REC_DETAIL.PAYMENTSTYPE != 3 then
            declare
              vliConsentID number;
            begin
              M__CONSENT.P_INS_CONSENT(D__CONSENT_TYPE_ => 2
                                     , BODY_ => null
                                     , CLAIM_ID_ => P_CLAIM_PAY_OUT_
                                     , CLAIM_TYPE_ => 1
                                     , G_PERSON_ => G_PERSON_
                                     , DO_COMMIT_ => 0
                                     , CONSENT_KIND_ => 1
                                     , STATUS_ => 1
                                     , PERSON_TYPE_ => 0
                                     , P_CONSENT_ => vliConsentID
                                     , ERR_CODE => ERRCODE
                                     , ERR_MSG => ERRMSG);
              if ERRCODE <> 0 then
                ERRCODE := 0;
                ERRMSG := ' ';
              end if;
            end;
          end if;

          --03.06.2020 йЕКДЕЬЕБ ю.ю. еЯКХ ЯХЯРЕЛМЮЪ НЬХАЙЮ, МЮОПХЛЕП ДНЯРСОЮ МЕР Й ХЯРНПХВЕЯЙНИ АЮГЕ, РН ЛШ ЯНУПЮМЪЕЛ Б ЙНЛЕМРЮПХХ Й ГЮЪБКЕМХЧ МЮ БШОКЮРС
          -- http://enpf24.kz/company/personal/user/3316/tasks/task/view/514116/
          select count(*) into cnt_
          from p_claim_po_comment# t
          where t.p_claim_po_comment = 1
            and t.p_claim_pay_out = 1
            and t.comments is not null;

          if cnt_ > 0 then
            insert into p_claim_po_comment (p_claim_po_comment, p_claim_pay_out, comments, sys_date, id_user)
            select seq_p_claim_po_comment.nextval, P_CLAIM_PAY_OUT_, t.comments, t.sys_date, t.id_user
              from p_claim_po_comment# t
             where t.p_claim_po_comment = 1
               and t.p_claim_pay_out = 1
               and t.comments is not null;
          end if;

          P_CLAIM_PAY_OUT_ARR_(P) := P_CLAIM_PAY_OUT_;
          P := P + 1;

          if P_G_CONTRACT_KND_ IN (1,10) then            -- 08.10.2018 релейнб юю, гюдювю 187980, днцнбнп рд рнфе мюдн свхршбюрэ
            P_CONTRACT_OPV_       := P_CONTRACTARR_(I);
            P_CLAIM_PAY_OUT_OPV_  := P_CLAIM_PAY_OUT_;
          elsif P_G_CONTRACT_KND_ = 18 then
            P_CONTRACT_OPPV_        := P_CONTRACTARR_(I);
            P_CLALIM_PAY_OUT_OPPV_  := P_CLAIM_PAY_OUT_;
          elsif P_G_CONTRACT_KND_ = 11 then
            P_CONTRACT_DPV_        := P_CONTRACTARR_(I);
            P_CLALIM_PAY_OUT_DPV_  := P_CLAIM_PAY_OUT_;
          end if;
        end loop;
      end if;

      -- еякх еярэ опедсопефдючыхе ньхайх, рн ярюбкч яннрберярбсчыхи ярюрся
      if (WARNMSGARR.COUNT > 0 OR WARNMSGARRяREGULAR.COUNT > 0) and PROC_SIGN_ = 1 then
        PROC_SIGN_ := 2;
      end if;

      --06.05.2020: люлернб я.ю. ядекюел хглемемхъ, рюй йюй акнй он бярюбйе гюохях б рюакхжс P_INGOING_PARSED_PENS оепемея бшье
      --х рнкэйн дкъ сяоеьмн напюанрюммшу гюохяеи, аег ньханй. дкъ ньханвмшу гюохяеи нярюбкч йюй еярэ, йюй ашкн пюмее
      if ERRCODE = 0 and PROC_SIGN_ IN (1, 2) then
        BLOCK_ := '15 - бярюбйю дерюкеи P_INGOING_PARSED_PENS';
        update MAIN.P_INGOING_PARSED_PENS PP
           SET PP.PROCEED_SIGN = PROC_SIGN_,
               PP.P_CONTRACT_OPV = P_CONTRACT_OPV_,
               PP.P_CLAIM_PAY_OUT_OPV = P_CLAIM_PAY_OUT_OPV_,
               PP.P_CONTRACT_OPPV = P_CONTRACT_OPPV_,
               PP.P_CLALIM_PAY_OUT_OPPV = P_CLALIM_PAY_OUT_OPPV_,
               PP.G_PERSON = G_PERSON_
         where PP.P_INGOING_PARSED_PENS = P_INGOING_PARSED_PENS_;
      else
        BLOCK_ := '15 - бярюбйю дерюкеи P_INGOING_PARSED_PENS';
        insert into MAIN.P_INGOING_PARSED_PENS(
               P_INGOING_PARSED_PENS,            -- 1
               IIN,                              -- 2
               FM,                               -- 4
               NM,                               -- 5
               FT,                               -- 6
               DT,                               -- 7
               SEX,                              -- 8
               MOBILEPHONE,
               HOMEPHONE,
               EMAIL,
               APPLYNUMBERGK ,                   -- 10
               APPLYDATEGK ,                     -- 11
               QUEUE ,                           -- 12
               DEDUCTION,                        -- 14
               RESIDENCE,                        -- 15
               DISTRICT ,                        -- 16
               PROCEED_SIGN,
               P_INGOING_PARSED_ZON,
               P_INGOING_XML,
               P_CONTRACT_OPV,
               P_CLAIM_PAY_OUT_OPV,
               P_CONTRACT_OPPV,
               P_CLALIM_PAY_OUT_OPPV,
               P_CONTRACT_DPV,
               P_CLAIM_PAY_OUT_DPV
             , PAYMENTSTYPE
             , INCLUDEOPV
             , G_PERSON
             , ERR_CODE
             , ERR_MSG)            -- 22
        values(SEQ_P_INGOING_PARSED_PENS.NEXTVAL,   -- 1
               SUBSTR(REC_DETAIL.IIN, 1, 12),        -- 2
               REC_DETAIL.FM,                       -- 4
               REC_DETAIL.NM,                       -- 5
               REC_DETAIL.FT,                       -- 6
               DECODE(IS_DATE_DT_WRONG_, 2, NULL, DT_),                                 -- 7
               DECODE(IS_NUM_POL_WRONG_, 2, NULL, REC_DETAIL.SEX),                      -- 8
               SUBSTR(REC_DETAIL.MOBILEPHONE, 1, 12),
               SUBSTR(REC_DETAIL.HOMEPHONE, 1, 12),
               REC_DETAIL.EMAIL,
               REC_DETAIL.APPLYNUMBERGK,
               DECODE(IS_DATE_APPLYDATEGK_WRONG_, 2, NULL, APPLYDATEGK_),
               DECODE(IS_NUM_QUEUE_WRONG_, 2, NULL, REC_DETAIL.QUEUE),
               DECODE(IS_NUM_DEDUCT_WRONG_, 2, NULL, REC_DETAIL.DEDUCTION),             -- 14
               DECODE(IS_NUM_RESIDENCE_WRONG_, 2, NULL, REC_DETAIL.RESIDENCE),             -- 15
               DECODE(IS_NUM_DISTRICT_WRONG_, 2, NULL, REC_DETAIL.DISTRICT),             -- 16
               PROC_SIGN_,
               P_INGOING_PARSED_ZON_,
               P_INGOING_XML_,
               P_CONTRACT_OPV_,
               P_CLAIM_PAY_OUT_OPV_,
               P_CONTRACT_OPPV_,
               P_CLALIM_PAY_OUT_OPPV_,
               P_CONTRACT_DPV_,
               P_CLAIM_PAY_OUT_DPV_
             , DECODE(IS_PAYMENTSTYPE_WRONG_, 2, NULL, REC_DETAIL.PAYMENTSTYPE)
             , DECODE(IS_includeOPV_WRONG_, 2, NULL, REC_DETAIL.INCLUDEOPV)
             , G_PERSON_
             , ERRCODE
             , SUBSTR(ERRMSG,1,1023))
        return
          P_INGOING_PARSED_PENS
        into
          P_INGOING_PARSED_PENS_;
      end if;

     --Ekopylov 27.04.2020 гЮДЮВЮ 509954, ЕЯКХ БЯЕ УНПНЬН РН НРОПЮБКЪЕЛ Б НВЕПЕДЭ МЮ ОПНБЕПЙС Б цадтк
      if PROC_SIGN_ IN( 1, 2)  then
        DECLARE
          ERR_CODE_            NUMBER;
          ERR_MSG_             NUMBER;
        begin

          -- 15.12.2023 реоепэ ашбюер врн ноб днцнбнпю мер, онщрнлс бярюбкъел опнбепнвйс
          if P_CLAIM_PAY_OUT_OPV_ IS NOT NULL then
             P_INS_LT_GBDFL_PENS(V_IIN => REC_DETAIL.IIN,
                                 V_G_PERSON => G_PERSON_,
                                 V_STATUS => 0,
                                 V_CLAIM_PAY_OUT => P_CLAIM_PAY_OUT_OPV_,
                                 V_INGOING_PARSED_PENS => P_INGOING_PARSED_PENS_,
                                 ERR_CODE => ERR_CODE_,
                                 ERR_MSG => ERR_MSG_);
          end if;
          -- ашбюер врн еярэ днцнбнпю нооб ху рнфе мюдн нропюбхрэ б нвепедэ
          if P_CLALIM_PAY_OUT_OPPV_ IS NOT NULL then
             P_INS_LT_GBDFL_PENS(V_IIN => REC_DETAIL.IIN,
                                 V_G_PERSON => G_PERSON_,
                                 V_STATUS => 0,
                                 V_CLAIM_PAY_OUT => P_CLALIM_PAY_OUT_OPPV_,
                                 V_INGOING_PARSED_PENS => P_INGOING_PARSED_PENS_,
                                 ERR_CODE => ERR_CODE_,
                                 ERR_MSG => ERR_MSG_);
          end if;
          -- ашбюер врн еярэ днцнбнпю доб ху рнфе мюдн нропюбхрэ б нвепедэ
          if P_CLALIM_PAY_OUT_DPV_ IS NOT NULL then
             P_INS_LT_GBDFL_PENS(V_IIN => REC_DETAIL.IIN,
                                 V_G_PERSON => G_PERSON_,
                                 V_STATUS => 0,
                                 V_CLAIM_PAY_OUT => P_CLALIM_PAY_OUT_DPV_,
                                 V_INGOING_PARSED_PENS => P_INGOING_PARSED_PENS_,
                                 ERR_CODE => ERR_CODE_,
                                 ERR_MSG => ERR_MSG_);
          end if;
        exception
          when others then
            NULL;
        end;
      end if;

      -- бярюбйю ньханй он PENS опх меопедбхдеммшу ньхайюу
      BLOCK_ := '15.1 - бярюбйю дерюкеи P_INGOING_PARSED_PENS';
      if (ERRMSG IS NOT NULL) and (ERRCODE <> 0) then
        pl_InsERROR(P_INGOING_PARSED_PENS_,
                    ERRCODE,
                    ERRMSG,
                    ERRMSGGK
                    );
        NEGATIVEMSG_ := ERRMSG;
        CONTINUE;   -- сунфс мю якед. хрепюжхч
      end if;

      -- бярюбйю ньханй опх напюанрйе б опнжедспюу P_CHECK 1
      BLOCK_ := '15.2 - бярюбйю дерюкеи P_INGOING_PARSED_PENS';
      DECLARE
        FLAG_ INTEGER := 0;
      begin
        if ERRMSGARR.COUNT > 0 then
          for I IN 0..ERRMSGARR.COUNT-1 loop
            pl_InsERROR(P_INGOING_PARSED_PENS_,
                        ERRMSGARR(I).ERRCODE,
                        ERRMSGARR(I).ERRMSGENPF,
                        ERRMSGARR(I).ERRMSGGK
                        );
            NEGATIVEMSG_    := NEGATIVEMSG_||ERRMSGARR(I).ErrMsgGk||CHR(13)||CHR(10);

            if ERRMSGARR(I).ERRCODE = 3 then
              FLAG_ := 1;
            end if;
          end loop;

          if FLAG_ = 1 then
            CONTINUE;   -- сунфс мю якед. хрепюжхч
          end if;
        end if;
      end;

      -- бярюбйю ньханй опх напюанрйе б опнжедспюу P_CHECK_PAY_CLAIM_PARAMS
      BLOCK_ := '15.3 - бярюбйю дерюкеи P_INGOING_PARSED_PENS';
      if ERRMSGARRяREGULAR.COUNT > 0 then
        for I IN 0..ERRMSGARRяREGULAR.COUNT-1 loop
          pl_InsERROR(P_INGOING_PARSED_PENS_,
                      ERRMSGARRяREGULAR(I).ERRCODE,
                      ERRMSGARRяREGULAR(I).ERRMSGENPF,
                      ERRMSGARRяREGULAR(I).ERRMSGGK
                      );

          NEGATIVEMSG_    := NEGATIVEMSG_||ERRMSGARRяREGULAR(I).ErrMsgGk||CHR(13)||CHR(10);
        end loop;
        continue;   -- сунфс мю якед. хрепюжхч
      end if;

      -- бярюбйю мюьху ньханй опх напюанрйе б опнжедспюу P_CHECK 2
      BLOCK_ := '15.3 - бярюбйю дерюкеи P_INGOING_PARSED_PENS';
      if ERRMSGARRяREGULAROUR.COUNT > 0 then
        for I IN 0..ERRMSGARRяREGULAROUR.COUNT-1 loop
          pl_InsERROR(P_INGOING_PARSED_PENS_,
                      ERRMSGARRяREGULAROUR(I).ERRCODE,
                      ERRMSGARRяREGULAROUR(I).ERRMSGENPF,
                      ERRMSGARRяREGULAROUR(I).ERRMSGGK
                      );

          NEGATIVEMSG_    := NEGATIVEMSG_||ERRMSGARRяREGULAROUR(I).ErrMsgEnpf||CHR(13)||CHR(10);
        end loop;
        continue;   -- сунфс мю якед. хрепюжхч
      end if;


      for I IN 0..WARNMSGARR.COUNT-1 loop        -- бярюбйю опедсопефдючыху ньханй опх напюанрйе б опнжедспюу P_CHECKS
        pl_InsERROR(P_INGOING_PARSED_PENS_,
                    WARNMSGARR(I).ERRCODE,
                    WARNMSGARR(I).ERRMSGENPF,
                    NULL
                    );
      end loop;

      for I IN 0..WARNMSGARRяREGULAR.COUNT-1 loop
        pl_InsERROR(P_INGOING_PARSED_PENS_,
                    WARNMSGARRяREGULAR(I).ERRCODE,
                    WARNMSGARRяREGULAR(I).ERRMSGENPF,
                    NULL
                    );
      end loop;

      -- еЯКХ БЯЕ МНПЛЮКЭМН, РН ЯНГДЮЧ ПЕЕЯРП Х ЙНППЕЙРХПСЧ ГЮЪБКЕМХЕ Б ЯННРБЕРЯРБХХ Я ОНЯРЮМНБЙНИ
      BLOCK_ := '16 - янгдюмхе пееярпю';
      begin
        select P_REESTR
        into P_REESTR_
        from ( -- 20190911 аШВЙНБ л. Б СЙЮГЮММНИ ДЮРЕ ОНЪБХКНЯЭ ДБЮ ПЕЕЯРПЮ (P_REESTR) Я НДМХЛ МНЛЕПНЛ (REESTR_NUM=00-20190911-0911), PENS ЯКНЛЮКЯЪ
              select P_REESTR
              from P_REESTR
              where TRUNC(REESTR_DATE) = TRUNC(SYSDATE)
                and SUBSTR(REESTR_NUM, INSTR(REESTR_NUM, '-', 5)+1) = To_Char(TRUNC(SYSDATE), 'MMDD')
                and G_FILIAL = 0
                and TYPE_REESTR = 1
              order by p_reestr) where rownum=1;
      exception
        when NO_DATA_FOUND then
          insert into P_REESTR
            (P_REESTR, TYPE_REESTR, G_FILIAL, REESTR_NUM, REESTR_DATE)
          values
            (SEQ_P_REESTR.NEXTVAL,
             1,
             0,
             '00-'||To_Char(SYSDATE, 'YYYYMMDD')||'-'||To_Char(To_Char(TRUNC(SYSDATE), 'MMDD')), -- CODE_
             TRUNC(SYSDATE))
          returning P_REESTR
          into P_REESTR_;
      end;

      -- бярюбкъч ябъгэ гюъбкемхъ я P_INGOING_PENS х йнппейрхпсч гюъбкемхе блеяре я дя
      BLOCK_ := '17 - хглемемхе гюъбкемхъ';
      for I IN 0..P_CLAIM_PAY_OUT_ARR_.COUNT - 1 loop
        update P_CLAIM_PAY_OUT PP --(!) update P_CLAIM_PAY_OUT$$O PP
           SET PP.P_INGOING_PARSED_PENS = P_INGOING_PARSED_PENS_,
               PP.CLAIM_NUM = PP.CLAIM_NUM||decode(pp.P_G_REGISTRATION_PLACE,7,'-цй',9,'-ос',10,'-що'),
               PP.P_G_CLAIM_STATUS = 3,
               PP.EXT_IS_CONFIRM_FRONTOFFICE = 1,
               PP.EXT_IS_CONFIRM_FR_OFFICE_DATE = DATE_RECEPTION_,
               PP.EXT_IS_CONFIRM_FRONTOFFICE_USR = 50,
               PP.EXT_IS_CONFIRM_MIDLOFFICE = 1,
               PP.EXT_IS_CONFIRM_MIDLOFFICE_DATE = DATE_RECEPTION_,
               PP.EXT_IS_CONFIRM_MIDLOFFICE_USR = 50,
               PP.P_REESTR = P_REESTR_
         where PP.P_CLAIM_PAY_OUT_INITIAL = P_CLAIM_PAY_OUT_ARR_(I);

        -- бярюбкъч елс хярнпхч ярюрсянб 3, дслюч нярюкэмне бярюбкърэ кхьмее
        insert into P_CLAIM_PAY_OUT_OFFICIAL
          (P_CLAIM_PAY_OUT_OFFICIAL, P_CLAIM_PAY_OUT, OFFICIAL, P_G_CLAIM_STATUS, CONFIRM_DATE)
        values
          (SEC_P_CLAIM_PAY_OUT_OFFICIAL.NEXTVAL, P_CLAIM_PAY_OUT_ARR_(I), NVL(CONNECTION_PARAM.IDUSER, 100), 3, SYSDATE);


        declare        -- бЯРЮБКЪЧ ЕЛС ХЯРНПХЧ ЯРЮРСЯНБ 3 ДКЪ ДЯ, ДСЛЮЧ НЯРЮКЭМНЕ БЯРЮБКЪРЭ КХЬМЕЕ
          DS_  P_CLAIM_PAY_OUT.P_CLAIM_PAY_OUT%TYPE;
        begin
          select P.P_CLAIM_PAY_OUT
          into DS_
          from MAIN.P_CLAIM_PAY_OUT P --(!) from MAIN.P_CLAIM_PAY_OUT$$O P
          where P.P_CLAIM_PAY_OUT_INITIAL = P_CLAIM_PAY_OUT_ARR_(I)
            and P.P_G_CLAIM_PAY_OUT_KND = 4;

          insert into P_CLAIM_PAY_OUT_OFFICIAL
            (P_CLAIM_PAY_OUT_OFFICIAL, P_CLAIM_PAY_OUT, OFFICIAL, P_G_CLAIM_STATUS, CONFIRM_DATE)
          values
            (SEC_P_CLAIM_PAY_OUT_OFFICIAL.NEXTVAL, DS_, NVL(CONNECTION_PARAM.IDUSER, 100), 3, SYSDATE);
        end;

        -- яДЕКЮЧ РСР ФЕ ОНДЯВЕР ОПЕДБЮПХРЕКЭМНИ ЯСЛЛШ БШОКЮРШ
        BLOCK_ := '17.1 - ондявер опедбюпхрекэмни ясллш бшокюрш. ID '||P_CLAIM_PAY_OUT_ARR_(I);
        select T.SUMM_PAY
        into PREPAY_SUMM_
        from P_GRF T, P_GRFRCT TT
        where TT.P_CLAIM_PAY_OUT = (select P_CLAIM_PAY_OUT
                                    from P_CLAIM_PAY_OUT --(!) where TT.P_CLAIM_PAY_OUT = (select P_CLAIM_PAY_OUT from P_CLAIM_PAY_OUT$$O
                                    where P_CLAIM_PAY_OUT_INITIAL = P_CLAIM_PAY_OUT_ARR_(I)
                                      and P_G_CLAIM_PAY_OUT_KND = 4)
          and TT.P_GRFRCT = T.P_GRFRCT
          and T.NUM_TYPE = 1;

        PREPAY_SUMM_ALL_ := PREPAY_SUMM_ALL_ + PREPAY_SUMM_;

        -- йЮФДНЛС ГЮЪБКЕМХЧ РЕОЕПЭ ОПХБЪГШБЮЧ ДНЙСЛЕМРШ Б МНБСЧ РЮАКХЖС
        for REC IN (select STM.*
                    from XMLTABLE(XMLNAMESPACES(DEFAULT ''),
                                  '//document' PASSING XMLTYPE(BODY_FILE_)
                                  COLUMNS DOCNAME       VARCHAR2(250)  path 'docName',
                                          MIMETYPE      VARCHAR2(250)  path 'mimeType',
                                          URL           VARCHAR2(1024) path 'url',
                                          SENDMETHOD    VARCHAR2(250)  path 'sendMethod',
                                          FILEBODY      CLOB           path 'fileBody'
                                 ) STM
                   ) loop
          -- 06.05.2020 люлернб я.ю. он гюдюве б ахрпхйяе ╧512143 дя ╧ 2 х дя ╧ 3 онъбхкняэ бнглнфмнярэ нрйопюбкърэ днйслемрш ме рнкэйн йюй яяшкйю url
          -- мн х яюл назейр б бхде BASE64BINARY
          if LOWER(REC.SENDMETHOD) = 'file' then
            FILE_BODY_ := MAIN.M__LOB.FPBBASE64TOBLOB(REC.FILEBODY);
            /*ID_LOB_ := MAIN.M__LOB.FPISAVEBLOB (VLSFILENAME =>P_CLAIM_PAY_OUT_, vlsEXTFILE => REC.MIMETYPE, VLBBLOB => FILE_BODY_,
                                       vliERRCODE => ERR_CODE, vlsERRMSG => ERR_MSG);*/
            ID_LOB_ := NULL;
          end if;

          insert into MAIN.P_CLAIM_PAY_OUT_GKDOCS
            (P_CLAIM_PAY_OUT_GKDOCS, P_CLAIM_PAY_OUT, DOCNAME, MIMETYPE, URL, SEND_METHOD, FILE_BODY, ID_LOB)
          values
            (SEQ_P_CLAIM_PAY_OUT_GKDOCS.NEXTVAL, P_CLAIM_PAY_OUT_ARR_(I), REC.DOCNAME, REC.MIMETYPE, REC.URL, REC.SENDMETHOD, FILE_BODY_, ID_LOB_);  --15.10.2018 релейнб юю гюдювю 274952 мюдн апюрэ гюъбкемхе хг люяяхбю
        end loop;  --- for REC IN (select STM.*
      end loop;    --- for I IN 0..P_CLAIM_PAY_OUT_ARR_.COUNT - 1 loop
    end loop;

    BLOCK_ := '18 - янупюмъел гюопня оепед нропюбйни б цжбо';
    insert into MAIN.P_OUTGOING_XML(P_OUTGOING_XML,MESSAGE_ID,CORRELATION_ID,MESSAGE_TYPE,DATA,SYS_DATE,STATUS,ERR_MSG)
    values (SEQ_P_OUTGOING_XML.NEXTVAL, RESPONSE_ID_, MESSAGE_ID_, 'PENSO', NULL, SYSDATE, 1, NULL )
    returning P_OUTGOING_XML into P_OUTGOING_XML_;

    BLOCK_ := '19 - бярюбйю б дерюкх хяундъыецн нрберю ';
    -- дкъ бярюбйх б дерюкх мсфмю опедбюпхрекэмюъ ясллю бшокюрш, ю щрн ясллюпмне гмювемхе оепбни бшокюрш
    -- он цпютхйс он бяел гюъбкемхъл мю бшокюрс, бшвхякъеряъ бшье
    if PROC_SIGN_ IN (1,2) then
      result_ := 1;
    else
      result_ := 0;
    end if;



    insert into MAIN.P_OUTGOING_PARSED_PENSO(
                P_OUTGOING_PARSED_PENSO,
                P_G_OUTGOING_PROCEED_SIGN,
                IIN,
                STATUS,
                PRE_SUM_PAY,
                result_MESSAGE,
                P_OUTGOING_XML)
    values (SEQ_P_OUTGOING_PARSED_PENSO.NEXTVAL,
                0,
                IIN_,
                result_,
                PREPAY_SUMM_ALL_,
                SUBSTR(NEGATIVEMSG_, 1, 1000),    -- напефс мю бяъйхи яксвюи
                P_OUTGOING_XML_)
    returning P_OUTGOING_PARSED_PENSO into P_OUTGOING_PARSED_PENSO_;

    update P_INGOING_PARSED_PENS P
       SET P.P_OUTGOING_PARSED_PENSO = P_OUTGOING_PARSED_PENSO_
    where P.P_INGOING_PARSED_PENS = P_INGOING_PARSED_PENS_;

    BLOCK_ := '20 - янгдюмхе мнбнцн XML днйслемрю';
    DOM_ := DBMS_XMLDOM.NEWDOMDOCUMENT;
    ROOT_NODE_ := DBMS_XMLDOM.MAKENODE(DOM_);

    -- ROOT-рщц "PENSO"
    BLOCK_ := '21 - тнплхпнбюмхе йнпмебнцн рщцю PENSO';
    ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'PENSO');
    PENSO_NODE_ := DBMS_XMLDOM.APPENDCHILD(ROOT_NODE_,DBMS_XMLDOM.MAKENODE(ELEMENT_));

    -- еЯКХ ПЕГСКЭРЮР -1, Р.Е. АШКХ МЮЬХ НЬХАЙХ, РН БНГБПЮЫЮЧ ОСЯРНЕ ЯННАЫЕМХЕ
    if PROC_SIGN_ <> -1 then
      -- ххм
      BLOCK_ := '22 - тнплхпнбюмхе йнпмебнцн рщцю IIN';
      ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'IIN');
      NODE_ := DBMS_XMLDOM.APPENDCHILD(PENSO_NODE_, DBMS_XMLDOM.MAKENODE(ELEMENT_));
      NODE_TEXT := DBMS_XMLDOM.CREATETEXTNODE(DOM_, IIN_);
      NODE_ := DBMS_XMLDOM.APPENDCHILD(NODE_, DBMS_XMLDOM.MAKENODE(NODE_TEXT));

      -- result
      BLOCK_ := '23 - тнплхпнбюмхе йнпмебнцн рщцю result';
      ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'result');
      NODE_ := DBMS_XMLDOM.APPENDCHILD(PENSO_NODE_, DBMS_XMLDOM.MAKENODE(ELEMENT_));
      NODE_TEXT := DBMS_XMLDOM.CREATETEXTNODE(DOM_, result_);

      NODE_ := DBMS_XMLDOM.APPENDCHILD(NODE_, DBMS_XMLDOM.MAKENODE(NODE_TEXT));

      -- resultMESSAGE
      if PROC_SIGN_ IN (1,2) then
        NEGATIVEMSG_ := 'Б емот ГЮПЕЦХЯРПХПНБЮМН ГЮЪБКЕМХЕ МЮ БШОКЮРС ОЕМЯХНММШУ МЮЙНОКЕМХИ, ОКЮМХПСЕРЯЪ НЯСЫЕЯРБКЕМХЕ ОЕМЯХНММШУ БШОКЮР';
      end if;
      if INSTR(NEGATIVEMSG_, CHR(10)) > 0 then
        NEGATIVEMSG_ := SUBSTR(NEGATIVEMSG_, 1, INSTR(NEGATIVEMSG_, CHR(10)) - 2);   --сахпюч онякедмхи оепемня ярпнйх
      end if;
      BLOCK_ := '24 - тнплхпнбюмхе йнпмебнцн рщцю resultMESSAGE';
      ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'resultMessage');
      NODE_ := DBMS_XMLDOM.APPENDCHILD(PENSO_NODE_, DBMS_XMLDOM.MAKENODE(ELEMENT_));
      NODE_TEXT := DBMS_XMLDOM.CREATETEXTNODE(DOM_, NEGATIVEMSG_);
      NODE_ := DBMS_XMLDOM.APPENDCHILD(NODE_, DBMS_XMLDOM.MAKENODE(NODE_TEXT));

      -- SUMM
      BLOCK_ := '25 - тнплхпнбюмхе йнпмебнцн рщцю SUMM';
      ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'summ');
      NODE_ := DBMS_XMLDOM.APPENDCHILD(PENSO_NODE_, DBMS_XMLDOM.MAKENODE(ELEMENT_));
      NODE_TEXT := DBMS_XMLDOM.CREATETEXTNODE(DOM_, PREPAY_SUMM_ALL_);
      NODE_ := DBMS_XMLDOM.APPENDCHILD(NODE_, DBMS_XMLDOM.MAKENODE(NODE_TEXT));

      -- тхн НРБЕРЯРБЕММНЦН КХЖЮ, ОНЙЮ МЕ ЯЙЮГЮКХ НРЙСДЮ АПЮРЭ
      BLOCK_ := '25.1 - тнплхпнбюмхе йнпмебнцн рщцю EMPLOYEE';
      ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'employee');
      EMPLOYEE_NODE_ := DBMS_XMLDOM.APPENDCHILD(PENSO_NODE_, DBMS_XMLDOM.MAKENODE(ELEMENT_));

      declare
        lastName_    G_JUR_PERSON.Chief_Fm%type;
        firstName_   G_JUR_PERSON.CHIEF_NM%type;
        middleName_  G_JUR_PERSON.CHIEF_FT%type;
        position_    G_JUR_PERSON.Chief_Appointment%type;
        bin_         G_JUR_PERSON.IDN%TYPE;
      begin
        begin
          select JP.CHIEF_FM, JP.CHIEF_NM, JP.CHIEF_FT, JP.CHIEF_APPOINTMENT, PARAMS.GET_SYSTEM_SETUP_PARAM('CHIEF_IDN')
          into lastName_, firstName_, middleName_, position_, bin_
          from G_JUR_PERSON JP
          where JP.IDN = '971240002115'
            and JP.PENS_FOND_CODE = '24';
        exception
          when others then
            null;
        end;

        BLOCK_ := '25.2 - тнплхпнбюмхе йнпмебнцн рщцю POSITION';
        ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'position');
        NODE_ := DBMS_XMLDOM.APPENDCHILD(EMPLOYEE_NODE_, DBMS_XMLDOM.MAKENODE(ELEMENT_));
        NODE_TEXT := DBMS_XMLDOM.CREATETEXTNODE(DOM_, position_);
        NODE_ := DBMS_XMLDOM.APPENDCHILD(NODE_, DBMS_XMLDOM.MAKENODE(NODE_TEXT));

        BLOCK_ := '25.3 - тнплхпнбюмхе йнпмебнцн рщцю LASTNAME';
        ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'lastName');
        NODE_ := DBMS_XMLDOM.APPENDCHILD(EMPLOYEE_NODE_, DBMS_XMLDOM.MAKENODE(ELEMENT_));
        NODE_TEXT := DBMS_XMLDOM.CREATETEXTNODE(DOM_, lastName_);
        NODE_ := DBMS_XMLDOM.APPENDCHILD(NODE_, DBMS_XMLDOM.MAKENODE(NODE_TEXT));

        BLOCK_ := '25.4 - тнплхпнбюмхе йнпмебнцн рщцю FIRSTNAME';
        ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'firstName');
        NODE_ := DBMS_XMLDOM.APPENDCHILD(EMPLOYEE_NODE_, DBMS_XMLDOM.MAKENODE(ELEMENT_));
        NODE_TEXT := DBMS_XMLDOM.CREATETEXTNODE(DOM_, firstName_);
        NODE_ := DBMS_XMLDOM.APPENDCHILD(NODE_, DBMS_XMLDOM.MAKENODE(NODE_TEXT));

        BLOCK_ := '25.5 - тнплхпнбюмхе йнпмебнцн рщцю MIDDLENAME';
        ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'middleName');
        NODE_ := DBMS_XMLDOM.APPENDCHILD(EMPLOYEE_NODE_, DBMS_XMLDOM.MAKENODE(ELEMENT_));
        NODE_TEXT := DBMS_XMLDOM.CREATETEXTNODE(DOM_, middleName_);
        NODE_ := DBMS_XMLDOM.APPENDCHILD(NODE_, DBMS_XMLDOM.MAKENODE(NODE_TEXT));

        BLOCK_ := '25.6 - тнплхпнбюмхе йнпмебнцн рщцю IIN';
        ELEMENT_ := DBMS_XMLDOM.CREATEELEMENT(DOM_,'IIN');
        NODE_ := DBMS_XMLDOM.APPENDCHILD(EMPLOYEE_NODE_, DBMS_XMLDOM.MAKENODE(ELEMENT_));
        NODE_TEXT := DBMS_XMLDOM.CREATETEXTNODE(DOM_, bin_);
        NODE_ := DBMS_XMLDOM.APPENDCHILD(NODE_, DBMS_XMLDOM.MAKENODE(NODE_TEXT));
      end;
    end if;

    BLOCK_ := '26 - опенапюгнбюмхе онксвеммнцн XML б CLOB';
    PENSO_BODY_ := DBMS_XMLDOM.GETXMLTYPE(DOM_);
    DATA_ := PENSO_BODY_.GETCLOBVAL;

    if PROC_SIGN_ = -1 /*IN (-1, 3)*/ then
      ERR_CODE := -2;
      ERR_MSG := NEGATIVEMSG_;
    end if;

    update MAIN.P_OUTGOING_XML
       SET DATA = DATA_
    where P_OUTGOING_XML = P_OUTGOING_XML_;

    BLOB_DATA_ := MAIN.CLOB_TO_BLOB(MAIN.KAK_GET_CORRECT_UTF_KAZ(DATA_));

    -- 01.04.2021  люлернб яепхй б пюлйюу гюдювх б ахрпхйяе ╧ 599199 пюгпюанрйю х пеюкхгюжхъ тсмйжхнмюкю он пюяверс пюглепю оемяхнммшу бшокюр
    -- б яннрберярбхх я лерндхйни нясыеярбкемхъ пюяверю пюглепю оемяхнммшу бшокюр онъбхкюяэ менаундхлнярэ опнбепърэ мюкхвхе хмбюкхдмнярх он йюфднлс бйкюдвхйс/онксвюрекч
    -- хг тюикю PENS мю мюкхвхе кэцнрш
    CALL_P00(IIN_);
  end if;  --- --- if PARAMS.GET_SYSTEM_SETUP_PARAM('GK_MODE_ON') = 0 then

  -- дНАЮБКЕМН 30.01.2020 аШВЙНБ л.
  if P_exception_PENS_ IS NOT NULL then
    update MAIN.P_exception_PENS E
       SET E.IS_ACTIVE = 0,
           E.DATE_ACTIVATE = SYSDATE,
           E.P_INGOING_PARSED_PENS = P_INGOING_PARSED_PENS_
    where E.P_exception_PENS = P_exception_PENS_;
  end if;
  ---------------------------------
  if DO_COMMIT_ = 1 then
    commit;
  end if;
exception
  when TYPES.E_FORCE_EXIT then
    rollback;
    if DO_COMMIT_ = 1 then
      update MAIN.P_INGOING_XML I SET I.ERR_MSG=V_ERR_MSG, I.STATUS=-2 where I.P_INGOING_XML=P_INGOING_XML_;
      commit;
    end if;
    P_INGOING_PARSED_PENS_ := NULL;
    ERR_CODE := V_ERR_CODE;
    ERR_MSG  := PROCNAME || ' ' || BLOCK_ || ' ' || V_ERR_MSG;
    main.pp_Save_ERROR('p_Parse_Insert_Pens[TYPES.E_FORCE_EXIT] ['||nvl(Dbms_Utility.FORMAT_ERROR_BACKTRACE,'-=NULL=-')||'] ['||vlcLogs||'] ['||vlcLogStep||'] '||SUBSTR(SQLERRM, 1, 1000));
  when others then
    rollback;
    V_ERR_MSG := SQLERRM;
    if DO_COMMIT_ = 1 then
       update MAIN.P_INGOING_XML I SET I.ERR_MSG=V_ERR_MSG, I.STATUS=-2 where I.P_INGOING_XML=P_INGOING_XML_;
       commit;
    end if;
    P_INGOING_PARSED_PENS_ := NULL;
    ERR_CODE := -20500;
    ERR_MSG  := PROCNAME || ' ' || BLOCK_ || ' ' || SQLERRM;

    main.pp_Save_ERROR('p_Parse_Insert_Pens['||nvl(Dbms_Utility.FORMAT_ERROR_BACKTRACE,'-=NULL=-')||'] ['||vlcLogs||'] ['||vlcLogStep||'] '||SUBSTR(SQLERRM, 1, 1000));

END P_PARSE_INSERT_PENS;
/
