#include "G29Input.h"
#include <QtMath>
#include <linux/input.h>
#include <fcntl.h>
#include <unistd.h>
#include <QDebug>

#define PEDAL_MIN 0
#define PEDAL_MAX 255      //Accelerator range
#define MAX_SPEED 180

G29Input::G29Input(QObject *parent)
    : QObject(parent),
    m_speedKmh(0),
    m_targetSpeed(0),
    m_fd(-1),
    m_lastPedalValue(0),
    m_pedalInitialized(false)
{
    m_fd = open("/dev/input/event6", O_RDONLY | O_NONBLOCK);
    if (m_fd < 0)
        qWarning() << "Failed to open G29 input device";

    QTimer *timer = new QTimer(this);
    connect(timer, &QTimer::timeout, this, &G29Input::readPedal);
    timer->start(20); // 50 Hz
}

int G29Input::speedKmh() const
{
    return m_speedKmh;
}

void G29Input::readPedal()
{
    if (m_fd < 0)
        return;

    struct input_event ev;

    // Read all pending events
    while (read(m_fd, &ev, sizeof(ev)) > 0) {
        if (ev.type == EV_ABS && ev.code == ABS_Z) {
            m_lastPedalValue = ev.value;   // 0–255
            m_pedalInitialized = true;     // FIRST REAL INPUT
        }
    }

    //first pedal event arrives
    if (!m_pedalInitialized)
        return;

    // Invert pedal (G29)
    int invertedPedal = PEDAL_MAX - m_lastPedalValue;

    // Normalize to percent
    int pedalPercent =
        (invertedPedal * 100) / PEDAL_MAX;

    pedalPercent = qBound(0, pedalPercent, 100);

    // Pedal → target speed
    m_targetSpeed = (pedalPercent * MAX_SPEED) / 100;

    // Smooth speed change
    if (m_speedKmh < m_targetSpeed)
        m_speedKmh += 2;
    else if (m_speedKmh > m_targetSpeed)
        m_speedKmh -= 4;

    m_speedKmh = qBound(0, m_speedKmh, MAX_SPEED);

    emit speedKmhChanged();
}


