CREATE OR REPLACE FUNCTION P_GET_RECIPIENT_SUMM_YEAR_REAL
  (
  P_CONTRACT_      IN NUMBER,
  DATE_            IN DATE, -- дюрю дкъ пюяверю нярюбьхуяъ оепхнднб, йюй опюбхкн пюбмн дюре пецхярпюжхх гюъбкемхъ
  P_CLAIM_PAY_OUT_ IN NUMBER default null, -- еякх гюъбкемхе еярэ, рн мсфмн наъгюрекэмн оепедюрэ, еякх гюъбкемхе рнкэйн янгдюеряъ, рн рнцдю оепедюбюрэ NULL
  --IGNORE_REMAIN_   IN PLS_INTEGER DEFAULT 0, -- 0-напегюрэ цнднбсч ясллс, еякх нмю лемэье нярюрйю, 1-ме напегюрэ, бнгбпюыюрэ цнднбсч ясллс он гюйнмс, дюфе еякх нярюрнй лемэье ме╗ (пюмэье щрн ашкн б оюпюлерпе IS_VIP_=-1)
  ERR_CODE         OUT NUMBER,
  ERR_MSG          OUT VARCHAR2
  ) RETURN NUMBER
IS
/*
   тсмйжхъ опедмюгмювемю дкъ бшвхякемхъ цнднбни ясллш рнкэйн он мнбнлс гюйнмндюрекэярбс я 01.01.2018
   мн б нркхвхе нр тсмйжхх P_GET_RECIPIENT_SUMM_YEAR_HYBR, йнрнпюъ бнгбпюыюер ренпхрхвеяйсч ясллс онкнфеммсч он гюйнмс - щрю тсмйжхъ бнгбпюыюер пеюкэмсч цнднбсч ясллс,
   р.е. я свернл врн ефелеяъвмюъ ясллю лнфер ашрэ опхпюбмемю й 54% опнфхрнвмнцн лхмхлслю х я свернл йнкхвеярбю нярюбьхуяъ оепхнднб
*/

  -- хЯРНПХЪ ХГЛЕМЕМХИ:
  -- дЮРЮ        йРН             Comments  ЦДЕ ХГЛЕМЪКНЯЭ
  -------------------------------------------------------------------------------------------------------------------------
  -- 07.12.2017  Omirbaev Timur  яНГДЮК МНБСЧ ТСМЙЖХЧ ДКЪ БШВХЯКЕМХЪ ЦНДНБНИ ЯСЛЛШ ОН МНБНЛС ГЮЙНМНДЮРЕКЭЯРБС Я 2018Ц.
  -- 29.03.2019  релейнбюю, гюдювю 296037, хмхжхюкхгхпнбюк оепелеммше  
  -------------------------------------------------------------------------------------------------------------------------------


  PROCNUM        CONSTANT TYPES.TPROC_NAME := 'P_GET_RECIPIENT_SUMM_YEAR_REAL';
  RESULT NUMBER;
  BLOCK_ VARCHAR2(255);
  ARR_MIN_PENS_ ARR_MIN_PENS_TYPE; -- люяяхб лхмхлюкэмшу оемяхи щрнцн цндю, ецн бнгбпюыюер тсмйжхъ он нопедекемхч цнднбни цхапхдмни ясллш
  IS_VIP_ NUMBER;
  VIP_KOEF_ NUMBER;
  LOW_SUM_YEAR_ NUMBER;
  v_ERR_CODE NUMBER;
  v_ERR_MSG VARCHAR2(1024);
  MONTH_SUMM_ NUMBER;
  MIN_LIVING_LEVEL_ NUMBER;
  DELITEL_ NUMBER;
  WORKING_DATE_ NUMBER;
  G_ACCOUNT_ NUMBER;
  CONTRACT_SUM_ NUMBER;
BEGIN
  ERR_CODE := 0;
  ERR_MSG  := '';
    
    -- бшгнб тсмйжхх цхапхдмн цнднбни ясллш
    BLOCK_ := '01 - бшгнб тсмйжхх цхапхдмн цнднбни ясллш';
    ARR_MIN_PENS_ := ARR_MIN_PENS_TYPE();
    LOW_SUM_YEAR_ := ROUND(P_GET_RECIPIENT_SUMM_YEAR_HYBR(P_CONTRACT_ => P_CONTRACT_,
                                                          DATE_ => DATE_,
                                                          SUMM_REMAIN_ => NULL,
                                                          IS_VIP_ => IS_VIP_,
                                                          P_CLAIM_PAY_OUT_ => P_CLAIM_PAY_OUT_,
                                                          IS_VIRTUAL_ => 0,
                                                          IGNORE_REMAIN_ => 0, -- ОЕПЕДЮЧ ГМЮВЕМХЕ 0 ВРНАШ ТСМЙЖХЪ БЕПМСКЮ ЛЮЙЯХЛЮКЭМСЧ ЦНДНБСЧ ЯСЛЛС Ю МЕ НЯРЮРНЙ ЕЯКХ НМ ЛЕМЭЬЕ ЦНДНБНИ ЯСЛЛШ
                                                          ARR_MIN_PENS_ => ARR_MIN_PENS_,
                                                          VIP_KOEF_ => VIP_KOEF_,
                                                          IS_OLD_ALGORITHM_ => 0, --опхгмюй напюанрйх гюъбкемхъ он ярюпнлс гюйнмндюрекэярбс, деиярбсчыецн дн 2018, еякх 1 - рн он ярюпнлс гюйнмндюрекэярбс, 0 - он мнбнлс
                                                          ERR_CODE => v_ERR_CODE,
                                                          ERR_MSG => v_ERR_MSG),2);
    IF V_ERR_CODE != 0 THEN
      RAISE TYPES.E_Force_Exit;
    END IF;
    
    -- нопедекемхе ясллш ефелеяъвмни бшокюрш
    BLOCK_ := '02 - декемхе цнднбни ясллш мю 12';
    MONTH_SUMM_ := ROUND(LOW_SUM_YEAR_/12, 2);
    
    BLOCK_ := '03 - онксвемхе 54% опнфхрнвмнцн лхмхлслю';
    MIN_LIVING_LEVEL_ := ROUND(GET_MIN_LIVING_LEVEL(DATE_) * 0.54,2);
    
    BLOCK_ := '04 - япюбмемхе леяъвмни ясллш я 54% опнфхрнвмнцн лхмхлслю';
    IF MONTH_SUMM_ < MIN_LIVING_LEVEL_ THEN
      MONTH_SUMM_ := MIN_LIVING_LEVEL_;
    END IF;
    
    BLOCK_ := '05 - нопедекемхе йнк-бю нярюбьхуяъ оепхнднб';
    DELITEL_ := 12 - (pension_pack.get_period_num(DATE_,12) - 1);
    
    BLOCK_ := '06 - нопедекемхе ясллш он нярюбьхляъ леяъжюл';
    RESULT := MONTH_SUMM_ * DELITEL_;
    
    BLOCK_ := '07 - нопедекемхе нярюрйю он днцнбнпс';
    WORKING_DATE_ := WORKING_DATE_PACK.GET_WORKING_DATE_BY_WORK_DATE(DATE_);
    G_ACCOUNT_ := PENSION_PACK.P_GET_G_ACCOUNT_IPC(P_CONTRACT_, 1);
    CONTRACT_SUM_ := ROUND(NVL(K_CURRENCY_COURSE_PACK.GET_PENSION_COURSE_REC(1, WORKING_DATE_),0) * NVL(PENSION_PACK.GET_ACCOUNT_OUTPUT_CU(G_ACCOUNT_, WORKING_DATE_, WORKING_DATE_),0), NVL(ADM.CONNECTION_PARAM.KZDIGIT,2));
    
    BLOCK_ := '08 - япюбмемхе бшвхякеммни ясллш я нярюрйнл';
    IF RESULT > CONTRACT_SUM_ THEN
      RESULT := CONTRACT_SUM_;
    END IF;
    
    RETURN RESULT;
EXCEPTION
  WHEN TYPES.E_Force_Exit THEN
    ERR_MSG  := PROCNUM || block_ ||' ' || v_ERR_MSG;
    ERR_CODE := v_ERR_CODE;
  
  WHEN OTHERS THEN
    ERR_CODE := SQLCODE;
    ERR_MSG  := PROCNUM || ' 00 ' || ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, SQLERRM)|| ' BLOCK_='||BLOCK_;

END P_GET_RECIPIENT_SUMM_YEAR_REAL;
/
