/ Copyright (c) Oracle Corporation 1996, 2000.  All Rights Reserved.
/
/ NAME
/   bbdus.msg     
/ DESCRIPTION
/   Error messages for Block Browser/Editor (BBED).
/ NOTES 
/
/ MODIFIED
/   vsrihari 07/25/00   - add HELP CORRUPT message
/   vsrihari 10/05/99   - make password messages generic
/   vsrihari 09/24/97 -	  add "Password:", "Invalid password" entry
/   etucker  07/29/97 -   replace lcc with lrm
/   anolan   05/14/97 -   Demo.
/   vsrihari 11/26/96 -   modifications for Oracle8
/   vsrihari 11/20/96 -   cleanup help messages
/   vsrihari 11/19/96 -   add invalid version message
/   vsrihari 09/22/96 -   add invalid data block subtype message
/   vsrihari 09/20/96 -   modify HELP DUMP message
/   vsrihari 09/15/96 -   add HELP COPY message
/   vsrihari 09/15/96 -   add BLOCK number message for VERIFY
/   vsrihari 09/10/96 -   change errmsg 205 for illegal DBA
/   vsrihari 09/05/96 -   add HELP /Nuf message
/   vsrihari 09/04/96 -   modify error ranges in 217
/   vsrihari 08/29/96 -   change errmsg 307
/   vsrihari 08/13/96  -  Creation	
/
/ 
/ Errors
/
/ KUTM Errors: 100-199
/
0100,  1,  "initialization of NLS default callbacks failed"
// *Cause:  lxldini() returned an error condition.
// *Action: This is a fatal error and should be reported.
0101,  1,  "initialization of NLS data loading failed"
// *Cause:  lxlinit() returned an error condition.
// *Action: This is a fatal error and should be reported.
0102,  1,  "LSF package failed to load"
// *Cause:  lpmloadpkg() was unable to load lsf (library strings) package.
// *Action: This is a fatal error and should be reported.
0103,  1,  "initialization of LSF package failed"
// *Cause:  lsfini() returned an error condition.
// *Action: This is a fatal error and should be reported.
0104,  1,  "initialization of parser heap failed"
// *Cause:  lmmhpinit() returned an error condition.
// *Action: Check that sufficient memory is available to BBED.
0105,  1,  "LRM error %s occurred during command line parsing"
// *Cause:  Error detected by LRM command-line parser.
// *Action: Lookup the error code in lrm.h for more information.
0106,  1,  "LRM error %s occurred on command-line argument %s"
// *Cause:  Error detected by LRM parser fetching a command-line argument.
// *Action: Check syntax of specified command-line argument.
0107,  1,  "unable to copy command-line arguments into internal buffer"
// *Cause:  LSFPFP macro returned an error during cmdline buffer manipulation.
// *Action: This error should be reported.
0108,  1,  "illegal BLOCKSIZE (%s) specified"
// *Cause:  Oracle blocksize must be a multiple of 512 bytes.
0109,  1,  "BIFILE must be specified"
// *Cause:  The Before-Image file must be specified to allow session rollback.
0110,  1,  "out of memory for dynamic allocation"
// *Cause:  lmmmalloc() failed to allocate memory.
0111,  1,  "initialization of LRM package failed"
// *Cause:  lrmini() returned an error condition.
0112,  1,  "Password: "
0113,  1,  "Invalid password. Please rerun utility with the correct password."
/
/ KUTP Errors: 200-299
/
0200,  1,  "invalid keyword (%s)"
0201,  1,  "invalid switch (/%s)"
0202,  1,  "invalid parameter (%s)"
0203,  1,  "incomplete/malformed command"
0204,  1,  "unmatched quote in parameter string"
0205,  1,  "illegal or out of range DBA (File %s, Block %s)"
// *Cause:  The file# or block# component is illegal or out of range
//	    based on the files and sizes in the listfile.
// *Action: If the dba is correct submit a modified listfile that includes
//          the file with the correct file size.
0206,  1,  "out of range offset (%s)"
0207,  1,  "invalid offset specifier (%s)"
// *Cause:  The specified symbol is not in the block or the indirect offset
//          value is out of range.
0208,  1,  "out of range WIDTH (%s)"
// *Cause:  Only WIDTH values 60-300 are valid.
0209,  1,  "invalid number (%s)"
0210,  1,  "no row at this offset"
0211,  1,  "location stack is empty"
0212,  1,  "search string not found"
0213,  1,  "no FIND string specified"
0214,  1,  "OS error %s occurred"
0215,  1,  "editing not allowed in BROWSE mode"
0216,  1,  "unable to assign: type mismatch between (%s, %s)"
// *Cause:  Source & target symbols must have the same fundamental type.
0217,  1,  "unable to assign: (%s) is out of range (%s, %s)"
// *Cause:  The assigned literal was out of range for the target symbol.
/
/ KUTF Errors:
/
0300,  1,  "unable to translate filename"
0301,  1,  "unable to create a filename object"
0302,  1,  "initialization of file object failed"
0303,  1,  "unable to open file '%s'"
// *Cause:  The file does not exist or has insufficient access permissions.
// *Action: Modify file permissions or restrict access to BROWSE.
0304,  1,  "unable to read from file '%s'"
0305,  1,  "unable to read from standard input"
// *Cause:  A read from stdin causes both stdout and stderr to be flushed.
//          One of these flushes probably failed due to an OS error.
0306,  1,  "unable to write to file '%s'"
// *Cause:  User does not have write permission on the file.
// *Action: Modify file permissions or restrict access to BROWSE.
0307,  1,  "incorrect blocksize (%s) or truncated file"
// *Cause:  Entire block could not be read from the file.
// *Action: Verify blocksize and check for file truncation.
0308,  1,  "seek error on file '%s'"
0309,  1,  "out of range block number (%s)"
0310,  1,  "no datafile specified"
0311,  1,  "unable to edit without a BIFILE"
0312,  1,  "no LISTFILE specified"
0313,  1,  "BIFILE blocksize (%s) does not match BBED (%s)"
0314,  1,  "invalid or corrupted BIFILE '%s'"
/
/ KUTB Errors:
/
0400,  1,  "invalid blocktype (%.2u)"
// *Cause:  The cache header blocktype is corrupted.
// *Action: Use MODIFY to patch the blocktype field, which is at the
//	    same byte offset in every Oracle block.
0401,  1,  "out of range array index (%s)"
// *Cause:  The array had fewer elements than the specified index.
// *Action: Valid array indices are 0 to (arrsize-1) inclusive.
0402,  1,  "operation only allowed for data/index blocks"
// *Cause:  Only blocks with blocktype 6 (data/index) permit this operation.
0403,  1,  "invalid DATA block subtype (%.2u) - valid values are 1, 2"
// *Cause:  Either the block is not a data block or the subtype is corrupted.
0404,  1,  "invalid version (%.2u)"
// *Cause:  The cache header version is corrupted.
// *Action: Use MODIFY to patch the version field, which is at the
//          same byte offset in every Oracle block.
/
/ KUTY Errors:
/
0450,  1,  "unknown symbol (%s)"
// *Cause:  No BBED symbol table entry exists for this symbol.
// *Action: Use MAP to look for the correct symbol. Report as an error
//          if the symbol is an on-disk structure in Oracle source code.
0451,  1,  "(%s) is not a member of structure (%s)"
// *Cause:  This symbol is not a member of the specified structure.
/
/ KUTV Log Messages:
/
500,    2, "DBVERIFY - Verification starting\nFILE = %s"
501,    2, "BLOCK = %u"
502,    2, "DBVERIFY - Verification complete"
503,    2, "Block %d failed with check code %u"
504,    2, "Total Blocks Examined         : %u"
505,    2, "Total Blocks Processed (Data) : %u"
506,    2, "Total Blocks Failing   (Data) : %u"
507,    2, "Total Blocks Processed (Index): %u"
508,    2, "Total Blocks Failing   (Index): %u"
509,    2, "Total Blocks Empty            : %u"
510,    2, "Total Blocks Marked Corrupt   : %u"
511,    2, "Total Blocks Influx           : %u"
520,    2, "Block %u is corrupt"
521,    2, "Block %u is influx - most likely media corrupt"
522,    2, " Version is illegal\n"
523,    2, " Type out of range\n"
524,    2, " Type is zero\n"
525,    2, " Block number mismatch\n"
526,    2, " Sequence is zero\n"
527,    2, " Incarnation is zero\n"
528,    2, " Checksum is incorrect\n"
/
/
/
/ Internal Errors
/
600,    4, "internal error, arguments [%s][%s][%s][%s]"
/
/
/ Help Messages
/
1000,  2,  "SET DBA [ dba | file#, block# ]\n"
1001,  2,  "SET FILENAME 'filename'\nSET FILE file#\n"
1002,  2,  "SET BLOCK [+/-]block#\n"
1003,  2,  "SET OFFSET [ [+/-]byte offset | symbol | *symbol ]\n"
1004,  2,  "SET BLOCKSIZE bytes\nSET LIST[FILE] 'filename'\n"
1005,  2,  "SET WIDTH character_count\nSET COUNT bytes_to_display\n"
1006,  2,  "SET IBASE [ HEX | OCT | DEC ]\nSET OBASE [ HEX | OCT | DEC ]\n"
1007,  2,  "SET MODE  [ BROWSE | EDIT ]\nSET SPOOL [ Y | N ]"
1011,  2,  "SHOW [ <SET parameter> | ALL ]"
1012,  2,  "MAP[/v] [ DBA | FILENAME | FILE | BLOCK ]"
1013,  2,  "DUMP[/v] [ DBA | FILENAME | FILE | BLOCK | OFFSET | COUNT ]"
1014,  2,  "MODIFY[/x|d|u|o|c] numeric/character string\n"
1015,  2,  "      [ DBA | FILE | FILENAME | BLOCK | OFFSET | symbol | *symbol ]"
1016,  2,  "ASSIGN[/x|d|u|o] <target spec>=<source spec>\n"
1017,  2,  "<target spec> : [ DBA | FILE | FILENAME | BLOCK | OFFSET | symbol | *symbol ]\n"
1018,  2,  "<source spec> : [ value | <target spec options> ]"
1020,  2,  "FIND[/x|d|u|o|c] numeric/character string [ TOP | CURR ]"
1021,  2,  "PRINT[/x|d|u|o|c] [ DBA | FILE | FILENAME | BLOCK | OFFSET | symbol | *symbol ]"
1022,  2,  "EXAMINE[/Nuf] [ DBA | FILE | FILENAME | BLOCK | OFFSET | symbol | *symbol ]"
1023,  2,  "PUSH [ DBA | FILE | FILENAME | BLOCK | OFFSET ]"
1024,  2,  "POP [ALL]"
1025,  2,  "INFO"
1026,  2,  "REVERT [ DBA | FILE | FILENAME | BLOCK ]"
1027,  2,  "SUM [ DBA | FILE | FILENAME | BLOCK ] [ APPLY ]"
1028,  2,  "UNDO"
1029,  2,  "VERIFY [ DBA | FILE | FILENAME | BLOCK ]"
1030,  2,  "HELP [ <bbed command> | ALL ]"
1031,  2,  "SET SHOW INFO MAP DUMP PRINT EXAMINE FIND COPY MODIFY ASSIGN SUM PUSH POP REVERT UNDO HELP VERIFY CORRUPT"
1032,  2,  "CORRUPT [ DBA | FILE | FILENAME | BLOCK ]"
1035,  2,  "</Nuf>:\nN - a number which specifies a repeat count.\n"
1036,  2,  "u - a letter which specifies a unit size:\n"
1037,  2,  "  b - b1, ub1 (byte)\n  h - b2, ub2 (half-word)\n  w - b4, ub4(word)\n"
1038,  2,  "  r - Oracle table/index row\n"
1039,  2,  "f - a letter which specifies a display format:\n"
1040,  2,  "  x - hexadecimal\n  d - decimal\n  u - unsigned decimal\n"
1041,  2,  "  o - octal\n  c - character (native)\n  n - Oracle number\n"
1042,  2,  "  t - Oracle date\n  i - Oracle rowid"
1045,  2,  "COPY [ DBA | FILE | FILENAME | BLOCK ] TO [ DBA | FILE | FILENAME | BLOCK ]"
/
/
/ OSD Messages
/

