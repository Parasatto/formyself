CREATE OR REPLACE FUNCTION P_GET_RECIPIENT_SUMM_YEAR
(
  G_PERSON_ IN NUMBER,
  DATE_     IN DATE,
  ERR_CODE OUT NUMBER,
  ERR_MSG  OUT VARCHAR2
) RETURN NUMBER
IS
/*
    ‘”Ќ ÷»я ¬џ„»—Ћя≈“ ћј —»ћјЋ№Ќ”ё √ќƒќ¬”ё —”ћћ” ѕќЋќ∆≈ЌЌ”ё ¬ Ћјƒ„» ”
    ћаксимальна€ годова€ сумма пенсионных выплат рассчитываетс€ в размере
    наибольшей из следующих величин:
    1)	тридцатикратного размера минимальной пенсии (размер минимальной пенсии должен задаватьс€
        в справочнике, справочник должен быть историческим);
    2)	двухсот п€тидес€ти тыс€ч тенге;
    3)	величины, рассчитанной как произведение суммы пенсионных накоплений
        на коэффициент текущей стоимости в соответствующем возрасте получател€
        согласно таблице

*/
  PROCNUM        CONSTANT TYPES.TPROC_NAME := 'P_GET_RECIPIENT_SUMM_YEAR';
  RESULT NUMBER;
  V1_    NUMBER;
  V2_    NUMBER;
  V3_    NUMBER;
  AGE_   NUMBER;
BEGIN

   V1_   := 30 * PENSION_PACK.GET_MIN_PENSION_SUMM(DATE_,ERR_CODE,ERR_MSG);

   V2_   := 250000;

   SELECT TRUNC((DATE_ - N.DT)/365)
     INTO AGE_
     FROM G_NAT_PERSON N
    WHERE N.G_PERSON = G_PERSON_;

   V3_   := PENSION_PACK.GET_WITHDRAW_KOEF( AGE_ ,ERR_CODE,ERR_MSG);

   RESULT := GREATEST(V1_,V2_,V3_);

   RETURN RESULT;

EXCEPTION
  WHEN OTHERS THEN
    ERR_CODE := SQLCODE;
    ERR_MSG  := PROCNUM || ' 00 ' || ADM.ERROR_PACK.GET_ERR_MSG('0000', ERR_CODE, SQLERRM);
END P_GET_RECIPIENT_SUMM_YEAR;

-- строка дл€ синонима и гранта в command window
-- CREATE OR REPLACE PUBLIC SYNONYM P_GET_RECIPIENT_SUMM_YEAR FOR MAIN.P_GET_RECIPIENT_SUMM_YEAR;
-- GRANT ALL ON P_GET_RECIPIENT_SUMM_YEAR TO ADM WITH GRANT OPTION;
/
