.ORIG x0

AND R2, R2, #0
ADD R2, R2, #15
ST R2, ARRAY

HALT

ARRAY .BLKW 4

.END
