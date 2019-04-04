
ktpass.exe -princ oracle/cmudb.trivadislabs.com@TRIVADISLABS.COM -mapuser cmudb -pass LAB01schulung -crypto ALL -ptype KRB5_NT_PRINCIPAL -out C:\vagrant\keytab.cmudb


ktpass.exe -princ oracle/db.trivadislabs.com@TRIVADISLABS.COM -mapuser db.trivadislabs.com -pass LAB01schulung -crypto ALL -ptype KRB5_NT_PRINCIPAL  -out C:\u00\app\oracle\network\admin\db.trivadislabs.com.keytab


ktpass.exe -princ oracle/cmudb@TRIVADISLABS.COM -mapuser cmudb -pass LAB01schulung -crypto ALL -ptype KRB5_NT_PRINCIPAL -out C:\vagrant\keytab.cmudb

certutil -ca.cert C:\vagrant\ad_root.cer

cmu patch?

setspn.exe -L "oracle/cmudb@TRIVADISLABS.COM"