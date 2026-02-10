#ifndef SDV_H
#define SDV_H

#include <QObject>
#include <QObject>
#include <QString>
#include <iostream>
#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sstream>
 #include <string>
#include <linux/input.h>

class SDV : public QObject
{
    Q_OBJECT
public:
    explicit SDV(QObject *parent = 0);
    Q_INVOKABLE unsigned int sendSpeed();
    Q_INVOKABLE unsigned int sendDoor();
    Q_INVOKABLE unsigned int sendFuel();
    Q_INVOKABLE unsigned int sendIcon();
    Q_INVOKABLE int sendgear();
    Q_INVOKABLE int sendSteering();
    Q_INVOKABLE int sendIndicator();
    //Q_INVOKABLE QString sendFrame();
    Q_INVOKABLE unsigned int sendTemp();
};

#endif // SDV_H
