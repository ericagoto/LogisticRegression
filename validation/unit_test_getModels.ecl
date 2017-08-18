IMPORT $.^ AS LR;
IMPORT ML_Core.Types AS Core_Types;
NumericField := Core_Types.NumericField;
DiscreteField := Core_Types.DiscreteField;

dep := DATASET(
       [{1, 1, 1, 0}, {1, 1, 2, 1},
        {1, 2, 1, 0}, {1, 2, 2, 1},
        {1, 3, 1, 0}, {1, 3, 2, 1},
        {1, 4, 1, 0}, {1, 4, 2, 1},
        {1, 5, 1, 0}, {1, 5, 2, 1},
        {1, 6, 1, 0}, {1, 6, 2, 1},
        {1, 7, 1, 1}, {1, 7, 2, 0},
        {1, 8, 1, 1}, {1, 8, 2, 0},
        {1, 9, 1, 1}, {1, 9, 2, 0},
        {2, 1, 1, 0}, {2, 1, 2, 1}, {2, 1, 3, 0},
        {2, 2, 1, 0}, {2, 2, 2, 1}, {2, 2, 3, 0},
        {2, 3, 1, 0}, {2, 3, 2, 1}, {2, 3, 3, 0},
        {2, 4, 1, 0}, {2, 4, 2, 0}, {2, 4, 3, 1},
        {2, 5, 1, 0}, {2, 5, 2, 0}, {2, 5, 3, 1},
        {2, 6, 1, 0}, {2, 6, 2, 0}, {2, 6, 3, 1},
        {2, 7, 1, 1}, {2, 7, 2, 0}, {2, 7, 3, 0},
        {2, 8, 1, 1}, {2, 8, 2, 0}, {2, 8, 3, 0},
        {2, 9, 1, 1}, {2, 9, 2, 0}, {2, 9, 3, 0},
        {3, 1, 1, 0},
        {3, 2, 1, 0},
        {3, 3, 1, 0},
        {3, 4, 1, 0},
        {3, 5, 1, 0},
        {3, 6, 1, 0},
        {3, 7, 1, 1},
        {3, 8, 1, 1},
        {3, 9, 1, 1}], DiscreteField);
ind0 := DATASET(
    [{1, 1, 1, .6}, {1, 1, 2, .7}, {1, 1, 3, .8},
     {1, 2, 1, .8}, {1, 2, 2, .7}, {1, 2, 3, .7},
     {1, 3, 1, .7}, {1, 3, 2, .8}, {1, 3, 3, .6},
     {1, 4, 1, .9}, {1, 4, 2, .7}, {1, 4, 3, .9},
     {1, 5, 1, .8}, {1, 5, 2, .9}, {1, 5, 3, .6},
     {1, 6, 1, .8}, {1, 6, 2, .5}, {1, 6, 3, .8},
     {1, 7, 1, .2}, {1, 7, 2,  0}, {1, 7, 3, .3},
     {1, 8, 1, .3}, {1, 8, 2, .4}, {1, 8, 3, .4},
     {1, 9, 1, .4}, {1, 9, 2, .7}, {1, 9, 3,  0},
     {2, 1, 1, .9}, {2, 1, 2, .7}, {2, 1, 3, .8},
     {2, 2, 1, .8}, {2, 2, 2, .7}, {2, 2, 3, .7},
     {2, 3, 1, .7}, {2, 3, 2, .8}, {2, 3, 3, .9},
     {2, 4, 1, .6}, {2, 4, 2, .5}, {2, 4, 3, .6},
     {2, 5, 1, .6}, {2, 5, 2, .6}, {2, 5, 3, .6},
     {2, 6, 1, .6}, {2, 6, 2, .5}, {2, 6, 3, .5},
     {2, 7, 1, .2}, {2, 7, 2, .1}, {2, 7, 3, .3},
     {2, 8, 1, .3}, {2, 8, 2, .4}, {2, 8, 3, .4},
     {2, 9, 1, .4}, {2, 9, 2, .7}, {2, 9, 3, .3},
     {3, 1, 1, .6}, {3, 1, 2, .7}, {3, 1, 3, .8},
     {3, 2, 1, .8}, {3, 2, 2, .7}, {3, 2, 3, .7},
     {3, 3, 1, .7}, {3, 3, 2, .8}, {3, 3, 3, .6},
     {3, 4, 1, .9}, {3, 4, 2, .7}, {3, 4, 3, .9},
     {3, 5, 1, .8}, {3, 5, 2, .9}, {3, 5, 3, .6},
     {3, 6, 1, .8}, {3, 6, 2, .5}, {3, 6, 3, .8},
     {3, 7, 1, .2}, {3, 7, 2, .1}, {3, 7, 3, .3},
     {3, 8, 1, .3}, {3, 8, 2, .4}, {3, 8, 3, .4},
     {3, 9, 1, .4}, {3, 9, 2, .7}, {3, 9, 3, .3}], NumericField);
ind := WHEN(ind0, #STORED('LR_LOCAL_MATRIX_CAP', 20));
dep_nz := dep(value<>0);
ind_nz := ind(value<>0);
mod_g := LR.IRLS.getModel_global(ind_nz, dep_nz, 100, 0.0000001);
mod_l := LR.IRLS.getModel_local(ind_nz, dep_nz, 100, 0.0000001);

cmpr := RECORD
  UNSIGNED wi;
  UNSIGNED id;
  UNSIGNED number;
  REAL8 v_local;
  REAL8 v_global;
END;
diff := JOIN(mod_g, mod_l,
             LEFT.wi=RIGHT.wi AND LEFT.id=RIGHT.id AND LEFT.number=RIGHT.number
             AND ABS(LEFT.value-RIGHT.value) > 0.000001,
             TRANSFORM(cmpr, SELF.v_local:=RIGHT.value, SELF.v_global:=LEFT.value, SELF:=LEFT));
diff_rpt := OUTPUT(SORT(diff, wi, id, number), NAMED('Differences'));
global_out := OUTPUT(SORT(mod_g, wi, id, number), ALL, NAMED('Global_Model_Out'));
local_out := OUTPUT(SORT(mod_l, wi, id, number), ALL, NAMED('Local_Model_Out'));
EXPORT unit_test_getModels := SEQUENTIAL(diff_rpt, global_out, local_out);