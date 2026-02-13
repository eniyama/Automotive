#ifndef DROWSINESSDETECTOR_H
#define DROWSINESSDETECTOR_H

#include <QObject>
#include <QVideoSink>
#include <QVideoFrame>
#include <QMediaCaptureSession>
#include <QCamera>
#include <QElapsedTimer>
#include <QTimer>

class DrowsinessDetector : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool drowsinessAlertActive READ drowsinessAlertActive NOTIFY drowsinessAlertActiveChanged)
    Q_PROPERTY(bool cameraAvailable READ cameraAvailable NOTIFY cameraAvailableChanged)

public:
    explicit DrowsinessDetector(QObject *parent = nullptr);
    ~DrowsinessDetector();

    bool drowsinessAlertActive() const { return m_drowsinessAlertActive; }
    bool cameraAvailable() const { return m_cameraAvailable; }

    Q_INVOKABLE void startCamera();
    Q_INVOKABLE void stopCamera();
    /// Call from QML to test alert: triggerTestAlert(3000) shows alert for 3 seconds (console + UI).
    Q_INVOKABLE void triggerTestAlert(int durationMs = 3000);

signals:
    void drowsinessAlertActiveChanged();
    void cameraAvailableChanged();

private:
    void processFrame(const QVideoFrame &frame);
    void processOpenCVFrame();
    bool eyesClosedInFrame(const void *grayData, int width, int height, int bytesPerLine);
    void setDrowsinessAlertActive(bool active);

    QCamera *m_camera = nullptr;
    QMediaCaptureSession *m_captureSession = nullptr;
    QVideoSink *m_videoSink = nullptr;
    QTimer *m_captureTimer = nullptr;
    void *m_cvCapture = nullptr;

    bool m_drowsinessAlertActive = false;
    bool m_cameraAvailable = false;
    QElapsedTimer m_eyesClosedTimer;
    bool m_eyesClosedState = false;
    int m_consecutiveEyesOpenFrames = 0;
    static constexpr int kEyesClosedAlertMs = 2000;
    static constexpr int kEyesOpenFramesToReset = 3;
    QTimer *m_testAlertTimer = nullptr;

    void *m_cvDetector = nullptr; // opaque pointer to avoid including OpenCV in header
};

#endif // DROWSINESSDETECTOR_H
