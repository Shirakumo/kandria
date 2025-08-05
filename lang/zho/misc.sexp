load-screen-new-game "
Initiating cold boot
Checking processor ...                                             OK
Checking memory ...                                                OK
Checking disk ...                                                  OK
Checking aux ...                                                   OK
Checking clock ...                                                 OK
Checking power ...                                                 OK
Checking file system ...                                         WARN
Dirty bit set, replaying journal
Cleared orphaned inode 102325754
Cleared orphaned inode 102325754
Cleared orphaned inode 102325754
Cleared orphaned inode 102325754
Cleared orphaned inode 102325754
Cleared orphaned inode 102325754
Cleared orphaned inode 102325754
Cleared orphaned inode 102325754
Journal recovered
Checking motorbus ...                                              OK
Pinging motor system ...                                           OK
Waiting for motors to be ready ................................
...............................................................
...............................................................
................................ OK
Checking NFCS ...                                                  OK
Checking FFCS ...                                                  OK
Enumerating paired devices
EStuB_5 ...                                                        OK
EP/2_8 ...                                                    MISSING
Checking genbus ...                                                OK
Pinging genera ...                                                 OK
Bad shutdown detected, booting cold
[INFO] GENERA system starting up
[INFO] System information:
       ID: 525
       Base ver: 3305
       Core ver: 247
       Util ver: 554
       Last boot: 17.3.2368 03:32:02.7425 UTC
[WARN] Please service the GENERA system as soon as possible.
[INFO] Initiating cold boot
[INFO] Flushing network
[INFO] Waiting for response
[INFO] 524574230033347 replied within 0.01s
[INFO] Neuron coverage at 98.3%
[WARN] Coverage outside safe parameters!
[INFO] Checking base pattern response
[INFO] All OK
[INFO] Checking convolutional pattern response
[INFO] All OK
[INFO] Checking heuristic responses
[INFO] Nominal
[INFO] Imprinting last known status
[ERR ] Imprint incomplete or possibly damaged!
[INFO] Attempting to recover
[INFO] Rewriting network
[INFO] Checking response to last known state
[ERR ] Response mismatch!
[WARN] Restoring previous state failed! This may lead to memory
loss or erratic behaviour. Please service the GENERA system
immediately!
[INFO] Marking route to closest service facility
[ERR ] NFCS unavailable, failed to mark route
[INFO] Initiating core loop"
load-screen-load-game "
Initiating warm boot
Checking processor ...                                             OK
Checking memory ...                                                OK
Checking disk ...                                                  OK
Checking aux ...                                                   OK
Checking clock ...                                                 OK
Checking power ...                                                 OK
Checking file system ...                                           OK
Checking motorbus ...                                              OK
Pinging motor system ...                                           OK
Waiting for motors to be ready ................................
...............................................................
...............................................................
................................ OK
Checking NFCS ...                                                  OK
Checking FFCS ...                                                  OK
Enumerating paired devices
EStuB_5 ...                                                        OK
Checking genbus ...                                                OK
Pinging genera ...                                                 OK
[INFO] GENERA system starting up
[INFO] System information:
       ID: 525
       Base ver: 3305
       Core ver: 247
       Util ver: 554
[WARN] Please service the GENERA system as soon as possible.
[INFO] Restoring previous pattern
[INFO] Successfully restored previous pattern
[WARN] Servicing necessary
[INFO] Marking route to closest service facility
[ERR ] NFCS unavailable, failed to mark route
[INFO] Initiating core loop"
startup-credits-line "A game by Shinmera, Tim, Blob, Mikel, and Cai."
game-intro-notice "
这个游戏不使用自动保存。请经常保存！

如果你遇到困难，请查看多种游戏设置。"
critical-npc-death-ending "
机器人的Genera系统突然出现严重故障，
导致它杀死了视线内的任何人。

故障不断升级，内部融合堆芯失稳，
在初始故障后约 1.256 秒，
整个山谷被巨大的火球摧毁。

做得好！"
;; hints at a Calamity cause?...
zelah-early-death-ending "
随着他们的领袖被击败，Wraw的指挥体系迅速崩解。
山谷进入了不稳定的和平状态，但仍然是
和平。

做得好！"
;; don't name Zelah in this one, as fight could happen before you know his name (q6), and certainly before it's confirmed (q14) - it does appear on the health bar, but the player might miss this, so don't spoiler it
