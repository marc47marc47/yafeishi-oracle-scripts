CREATE OR REPLACE FUNCTION randomstrings (len NUMBER)
        RETURN VARCHAR2 PARALLEL_ENABLE is      -- string of <len> characters
        optx number  ;
        rng  NUMBER;
      --  n_p  number ;
        n    BINARY_INTEGER;
        i_1 number;
        i_2 number;
        i_3 number;
        i_4 number;
        ccs  VARCHAR2 (128);    -- candidate character subset
        xstr VARCHAR2 (4000) := NULL;
    BEGIN
        i_1 :=0;
        i_2 :=0;
        i_3 :=0;
        i_4 :=0;
        FOR i IN 1 ..least(len,4000) LOOP
          <<top>>
            /* Get random integer within specified range */
          --  n_p :=TRUNC(len * dbms_random.value) + 1;
            optx := mod( TRUNC(len * dbms_random.value) + 1,4);
            IF    optx = 0 THEN    -- upper case alpha characters only
                        ccs := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
                        rng := 26;
                        i_1 :=i_1+1;
                        n := TRUNC(rng* dbms_random.value) + 1;
                        if i_1 > 3 then
                           goto top;
                        end if;
            ELSIF optx = 1 THEN    -- lower case alpha characters only
                        ccs := 'abcdefghijklmnopqrstuvwxyz';
                        rng := 26;
                        i_2 :=i_2+1;
                        n := TRUNC(rng* dbms_random.value) + 1;
                        if i_2 > 2 then
                           goto top;
                        end if;
            ELSIF optx = 2 THEN    -- alpha characters only (mixed case)
                        ccs := '_';
                        rng := 1;
                        i_3 :=i_3+1;
                        n := TRUNC(rng* dbms_random.value) + 1;
                        if i_3 > 1 then
                           goto top;
                        end if;
            ELSIF optx = 3 THEN    -- any numeric characters
                        ccs := '0123456789';
                        rng := 10;
                        i_4 :=i_4+1;
                        n := TRUNC(rng* dbms_random.value) + 1;
                        if i_4 > 2 then
                           goto top;
                        end if;
             END IF;


            /* Append character to string  */
            xstr := xstr || SUBSTR(ccs,n,1);
        END LOOP;
        RETURN xstr;
    END randomstrings;