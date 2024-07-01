#ifndef GLOBALVARIABLES_H
#define GLOBALVARIABLES_H

#include <QtGlobal>
#include <string>

const int CHROME = 1,
    FIREFOX = 2,
    READER = 3,
    OFFICE = 4,
    ZOOM = 5;

std::string word = "xcopy \"C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Word.lnk\" \"%userprofile%\\Desktop\\\" /q /c\n";
std::string excel = "xcopy \"C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Excel.lnk\" \"%userprofile%\\Desktop\\\" /q /c\n";
std::string ppt = "xcopy \"C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Powerpoint.lnk\" \"%userprofile%\\Desktop\\\" /q /c\n";

const std::string OFFICEX = word + excel + ppt;

#endif //GLOBALVARIABLES_H
