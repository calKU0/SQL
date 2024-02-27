use CDNXL_GASKA
Update cdn.KntAdresy
set KnA_Telefon1 = REPLACE(KnA_Telefon1, '/', '')

use CDNXL_GASKA
Update cdn.KntAdresy
set KnA_Telefon1 = REPLACE(KnA_Telefon1, '-', '')

use CDNXL_GASKA
Update cdn.KntAdresy
set KnA_Telefon1 = REPLACE(KnA_Telefon1, ' ', '')
where KnA_Telefon1 != REPLACE(KnA_Telefon1, ' ', '')

use CDNXL_GASKA
Update cdn.KntAdresy
set KnA_Telefon1 = REPLACE(KnA_Telefon1, '+', '')
where KnA_Telefon1 != REPLACE(KnA_Telefon1, '+', '')

use CDNXL_GASKA
Update cdn.KntAdresy
set KnA_Telefon1 = REPLACE(KnA_Telefon1, '(', '')
where KnA_Telefon1 != REPLACE(KnA_Telefon1, '(', '')

use CDNXL_GASKA
Update cdn.KntAdresy
set KnA_Telefon1 = REPLACE(KnA_Telefon1, ')', '')
where KnA_Telefon1 != REPLACE(KnA_Telefon1, ')', '')

use CDNXL_GASKA
Update cdn.KntAdresy
set KnA_Telefon1 = LEFT(knA_telefon1, CHARINDEX (',', knA_telefon1) - 1)
from cdn.knTAdresy
where KnA_Telefon1 like('%,%')

use CDNXL_GASKA
Update cdn.KntAdresy
set KnA_Telefon1 = LEFT(knA_telefon1, CHARINDEX (';', knA_telefon1) - 1)
from cdn.knTAdresy
where KnA_Telefon1 like('%;%')

use CDNXL_GASKA
Update cdn.KntAdresy
set KnA_Telefon1 = LEFT(SUBSTRING(knA_telefon1, PATINDEX('%[0-9.-]%', knA_telefon1), 8000),
           PATINDEX('%[^0-9.-]%', SUBSTRING(knA_telefon1, PATINDEX('%[0-9.-]%', knA_telefon1), 8000) + 'X') -1)
where KnA_Telefon1 like ('%[A-Za-z]%')

use CDNXL_GASKA
Update cdn.KntAdresy
set KnA_Telefon1 = REPLACE(KnA_Telefon1, '.', '')
where KnA_Telefon1 != REPLACE(KnA_Telefon1, '.', '')

use CDNXL_GASKA
Update cdn.KntAdresy
set KnA_Telefon1 = REPLACE(KnA_Telefon1, '–', '')
where KnA_Telefon1 != REPLACE(KnA_Telefon1, '–', '')

use CDNXL_GASKA
Update cdn.KntAdresy
set KnA_Telefon1 = REPLACE(KnA_Telefon1, ' ', '')
where KnA_Telefon1 != REPLACE(KnA_Telefon1, ' ', '')

use CDNXL_GASKA
Update cdn.KntAdresy
set KnA_Telefon1 = REPLACE(KnA_Telefon1, '\', '')
where KnA_Telefon1 != REPLACE(KnA_Telefon1, '\', '')

use CDNXL_GASKA
Update cdn.KntAdresy
set KnA_Telefon1 = REPLACE(KnA_Telefon1, Char(10), '')
where KnA_Telefon1 != REPLACE(KnA_Telefon1, Char(10), '')

use CDNXL_GASKA
Update cdn.KntAdresy
set KnA_Telefon1 = REPLACE(KnA_Telefon1, ':', '')
where KnA_Telefon1 != REPLACE(KnA_Telefon1, ':', '')

use CDNXL_GASKA
Update cdn.KntAdresy
set KnA_Telefon1 = REPLACE(KnA_Telefon1, '·', '')
where KnA_Telefon1 != REPLACE(KnA_Telefon1, '·', '')




