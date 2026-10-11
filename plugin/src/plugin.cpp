// NimehOS plugin.cpp — QQmlExtensionPlugin entry point.
//
// In the Qt6 / qt_add_qml_module build model, types declared with the
// QML_ELEMENT macro are auto-registered into the module by the
// auto-generated qmlplugin_register() function. This class exists only to
// satisfy the Q_PLUGIN_METADATA requirement and to assert the URI at load
// time. It does not need to manually call qmlRegisterType<> for any type.

#include <QtQml/qqmlextensionplugin.h>
#include <QtQml/QQmlEngine>
#include <QString>

class NimehOSPlugin : public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
    void registerTypes(const char *uri) override {
        // Defensive: the URI is fixed by the CMake qt_add_qml_module call.
        // If someone imports a different URI the build is broken anyway,
        // but we assert to fail loud at load time rather than silently.
        Q_ASSERT(QLatin1String(uri) == QLatin1String("NimehOS"));
        Q_UNUSED(uri);
    }

    void initializeEngine(QQmlEngine *engine, const char *uri) override {
        Q_ASSERT(QLatin1String(uri) == QLatin1String("NimehOS"));
        Q_UNUSED(uri);
        // Future: register image providers, singletons, etc.
        Q_UNUSED(engine);
    }
};

#include "plugin.moc"
