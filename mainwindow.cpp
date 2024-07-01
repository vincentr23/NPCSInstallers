#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <queue>
#include "NPCSInstalls.h"

const int CHROME = 1,
    FIREFOX = 2,
    READER = 3,
    OFFICE = 4,
    ZOOM = 5;

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
}

MainWindow::~MainWindow()
{
    delete ui;
}

std::queue<int>temp;
void MainWindow::on_Install_clicked()
{
    if(ui->Chrome->isChecked())
        temp.push(CHROME);
    if(ui->Firefox->isChecked())
        temp.push(FIREFOX);
    if(ui->Reader->isChecked())
        temp.push(READER);
    if(ui->Office->isChecked())
        temp.push(OFFICE);
    if(ui->Zoom->isChecked())
        temp.push(ZOOM);

    installs(temp);
    MainWindow::close();

}


void MainWindow::on_Install_pressed()
{

}

