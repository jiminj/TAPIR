clear;
TapirConf;

convEncBlk = [1,1,1,1, -1,1,-1,1, -1,-1,-1,-1, -1,1,1,-1];
convEncBlk2 = [1,1,1,1, -1,1,-1,1, -1,-1,1,-1, -1,1,1,1];
decodedBlk = vitdec(convEncBlk, trel, 16, 'trunc', 'hard');
decodedBlk2 = vitdec(convEncBlk2, trel, 16, 'trunc', 'hard');

decodedBlk
decodedBlk2
