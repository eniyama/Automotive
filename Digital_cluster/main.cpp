#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "G29Input.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    G29Input g29;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("g29", &g29);
    engine.load(QUrl::fromLocalFile(
        QCoreApplication::applicationDirPath() + "/Main.qml"
        ));

    return app.exec();
}
