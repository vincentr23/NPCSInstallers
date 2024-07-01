/********************************************************************************
** Form generated from reading UI file 'mainwindow.ui'
**
** Created by: Qt User Interface Compiler version 6.7.2
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_MAINWINDOW_H
#define UI_MAINWINDOW_H

#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtWidgets/QApplication>
#include <QtWidgets/QCheckBox>
#include <QtWidgets/QGridLayout>
#include <QtWidgets/QMainWindow>
#include <QtWidgets/QMenu>
#include <QtWidgets/QMenuBar>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QStatusBar>
#include <QtWidgets/QWidget>

QT_BEGIN_NAMESPACE

class Ui_MainWindow
{
public:
    QWidget *centralwidget;
    QWidget *gridLayoutWidget;
    QGridLayout *gridLayout;
    QCheckBox *Office;
    QCheckBox *Reader;
    QCheckBox *Firefox;
    QCheckBox *Zoom;
    QCheckBox *Chrome;
    QPushButton *Install;
    QMenuBar *menubar;
    QMenu *menuNPCS_Installers;
    QStatusBar *statusbar;

    void setupUi(QMainWindow *MainWindow)
    {
        if (MainWindow->objectName().isEmpty())
            MainWindow->setObjectName("MainWindow");
        MainWindow->resize(444, 521);
        centralwidget = new QWidget(MainWindow);
        centralwidget->setObjectName("centralwidget");
        gridLayoutWidget = new QWidget(centralwidget);
        gridLayoutWidget->setObjectName("gridLayoutWidget");
        gridLayoutWidget->setGeometry(QRect(19, 9, 341, 351));
        gridLayout = new QGridLayout(gridLayoutWidget);
        gridLayout->setObjectName("gridLayout");
        gridLayout->setContentsMargins(0, 0, 0, 0);
        Office = new QCheckBox(gridLayoutWidget);
        Office->setObjectName("Office");

        gridLayout->addWidget(Office, 3, 0, 1, 1);

        Reader = new QCheckBox(gridLayoutWidget);
        Reader->setObjectName("Reader");

        gridLayout->addWidget(Reader, 2, 0, 1, 1);

        Firefox = new QCheckBox(gridLayoutWidget);
        Firefox->setObjectName("Firefox");

        gridLayout->addWidget(Firefox, 1, 0, 1, 1);

        Zoom = new QCheckBox(gridLayoutWidget);
        Zoom->setObjectName("Zoom");

        gridLayout->addWidget(Zoom, 4, 0, 1, 1);

        Chrome = new QCheckBox(gridLayoutWidget);
        Chrome->setObjectName("Chrome");

        gridLayout->addWidget(Chrome, 0, 0, 1, 1);

        Install = new QPushButton(centralwidget);
        Install->setObjectName("Install");
        Install->setGeometry(QRect(10, 450, 339, 24));
        MainWindow->setCentralWidget(centralwidget);
        menubar = new QMenuBar(MainWindow);
        menubar->setObjectName("menubar");
        menubar->setGeometry(QRect(0, 0, 444, 21));
        menuNPCS_Installers = new QMenu(menubar);
        menuNPCS_Installers->setObjectName("menuNPCS_Installers");
        MainWindow->setMenuBar(menubar);
        statusbar = new QStatusBar(MainWindow);
        statusbar->setObjectName("statusbar");
        MainWindow->setStatusBar(statusbar);

        menubar->addAction(menuNPCS_Installers->menuAction());

        retranslateUi(MainWindow);

        QMetaObject::connectSlotsByName(MainWindow);
    } // setupUi

    void retranslateUi(QMainWindow *MainWindow)
    {
        MainWindow->setWindowTitle(QCoreApplication::translate("MainWindow", "MainWindow", nullptr));
        Office->setText(QCoreApplication::translate("MainWindow", "Microsoft Office", nullptr));
        Reader->setText(QCoreApplication::translate("MainWindow", "Adobe Reader", nullptr));
        Firefox->setText(QCoreApplication::translate("MainWindow", "Mozilla Firefox", nullptr));
        Zoom->setText(QCoreApplication::translate("MainWindow", "Zoom", nullptr));
        Chrome->setText(QCoreApplication::translate("MainWindow", "Google Chrome", nullptr));
        Install->setText(QCoreApplication::translate("MainWindow", "Install", nullptr));
        menuNPCS_Installers->setTitle(QCoreApplication::translate("MainWindow", "NPCS Installers", nullptr));
    } // retranslateUi

};

namespace Ui {
    class MainWindow: public Ui_MainWindow {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_MAINWINDOW_H
