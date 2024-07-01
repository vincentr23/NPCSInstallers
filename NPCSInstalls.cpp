#include <iostream>
#include <string>
#include <fstream>
#include <queue>
#include "GlobalVariables.h"

std::string commands(int);

int installs(std::queue<int> qchecked)
{
    std::ofstream installers("installers.bat");
    std::ofstream choco("choco.ps1");
    installers << "@echo off" << std::endl;
    choco << "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))";
    choco.close();
    system("powershell -ExecutionPolicy Bypass -F choco.ps1");
    system("cls");
    remove("choco.ps1");

    while (!qchecked.empty())
    {
        installers << commands(qchecked.front()) << std::endl;
        qchecked.pop();
    }


    installers << "pause";
    installers.close();

    system("installers.bat");
    remove("installers.bat");

    return 0;
}


inline std::string commands(int num)
{
    switch (num)
    {
        case CHROME:
            return "choco install googlechrome -y";
        case FIREFOX:
            return "choco install firefox -y";
        case READER:
            return "choco install adobereader - y";
        case OFFICE:
            return OFFICEX;
        case ZOOM:
            return "choco install zoom -y";
        default:
            return "";
    }
}
