#ifndef G29INPUT_H
#define G29INPUT_H

#include <QObject>
#include <QTimer>
#include <linux/input.h>

class G29Input : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int speedKmh READ speedKmh NOTIFY speedKmhChanged)

public:
    explicit G29Input(QObject *parent = nullptr);

    int speedKmh() const;

signals:
    void speedKmhChanged();

private slots:
    void readPedal();

private:
    int m_speedKmh;
    int m_targetSpeed;
    int m_fd;               // /dev/input/event6
    int m_lastPedalValue; 
    bool m_pedalInitialized;


};

#endif // G29INPUT_H
