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
