(:source "dummy.ase"
 :animation-data "dummy.json"
 :animations ((STAND :loop-to 0 :next STAND)
              (JUMP :loop-to 1 :next FALL)
              (FALL :loop-to 4 :next FALL)
              (LIGHT-HIT :loop-to 10 :next STAND)
              (HARD-HIT :loop-to 21 :next STAND)
              (DIE :loop-to 27 :next DIE)))
