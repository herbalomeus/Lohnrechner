import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic


ApplicationWindow {
    id: window
    width: 400
    height: 550
    visible: true
    title: "Lohnrechner"

    // Eigenschaften für die interne Berechnung
    property real taxRate: 0.31       // Beispiel: 30% Abzüge (Steuern + Sozialabgaben)
    property real hoursPerWeek: 40.0  // Wochenstunden
    property real weeksPerMonth: 4.333 // Durchschnittliche Wochen pro Monat (52 / 12)

    // Flag zur Vermeidung von endlosen Aktualisierungsschleifen
    property bool isUpdating: false

    // Haupt-Hauptfunktion zur Umrechnung
    // baseValue: Der eingegebene Wert
    // inputType: "hourly", "monthly", oder "yearly"
    // isNet: true if input is Netto, false if Brutto
    function calculate(baseValue, inputType, isNet) {
        if (isUpdating || isNaN(baseValue)) return;
        isUpdating = true;

        var grossHourly = 0;

        // 1. Alles zuerst auf "Brutto pro Stunde" umrechnen
        if (isNet) {
            // Netto zu Brutto umrechnen
            var grossValue = baseValue / (1 - taxRate);
            if (inputType === "hourly") grossHourly = grossValue;
            else if (inputType === "monthly") grossHourly = grossValue / (hoursPerWeek * weeksPerMonth);
            else if (inputType === "yearly") grossHourly = grossValue / (hoursPerWeek * 52);
        } else {
            // Bereits Brutto
            if (inputType === "hourly") grossHourly = baseValue;
            else if (inputType === "monthly") grossHourly = baseValue / (hoursPerWeek * weeksPerMonth);
            else if (inputType === "yearly") grossHourly = baseValue / (hoursPerWeek * 52);
        }

        // 2. Alle Felder aus dem zentralen grossHourly-Wert berechnen
        var grossMonthly = grossHourly * hoursPerWeek * weeksPerMonth;
        var grossYearly = grossHourly * hoursPerWeek * 52;

        var netHourly = grossHourly * (1 - taxRate);
        var netMonthly = grossMonthly * (1 - taxRate);
        var netYearly = grossYearly * (1 - taxRate);

        // 3. UI-Felder aktualisieren
        hourlyGross.text = grossHourly.toFixed(2);
        monthlyGross.text = grossMonthly.toFixed(2);
        yearlyGross.text = grossYearly.toFixed(2);

        hourlyNet.text = netHourly.toFixed(2);
        monthlyNet.text = netMonthly.toFixed(2);
        yearlyNet.text = netYearly.toFixed(2);

        isUpdating = false;
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Text {
            text: "Lohn- & Gehaltsrechner"
            font.pixelSize: 20
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        // Einstellungen (Abzüge)
        RowLayout {
            Layout.fillWidth: true
            Text { text: "Geschätzte Abzüge (%):" }
            TextField {
                id: taxRateInput
                text: (window.taxRate * 100).toString()
                validator: DoubleValidator { bottom: 0; top: 100; decimals: 1 }
                Layout.preferredWidth: 60
                onTextChanged: {
                    window.taxRate = (parseFloat(text) || 0) / 100;
                    // Bei Änderung der Prozentzahl vom Monatsbrutto neu berechnen
                    calculate(parseFloat(monthlyGross.text) || 0, "monthly", false);
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#cccccc"
        }

        // Raster für die Eingabe- und Ausgabefelder
        GridLayout {
            columns: 3
            columnSpacing: 10
            rowSpacing: 10
            Layout.fillWidth: true

            // Header
            Text { text: ""; font.bold: true }
            Text { text: "Brutto (€)"; font.bold: true; Layout.alignment: Qt.AlignHCenter }
            Text { text: "Netto (€)"; font.bold: true; Layout.alignment: Qt.AlignHCenter }

            // Zeile: Stunde
            Text { text: "Pro Stunde:" }
            TextField {
                id: hourlyGross
                placeholderText: "0.00"
                validator: DoubleValidator { bottom: 0; decimals: 2 }
                onTextChanged: calculate(parseFloat(text) || 0, "hourly", false)
            }
            TextField {
                id: hourlyNet
                placeholderText: "0.00"
                validator: DoubleValidator { bottom: 0; decimals: 2 }
                onTextChanged: calculate(parseFloat(text) || 0, "hourly", true)
            }

            // Zeile: Monat
            Text { text: "Pro Monat:" }
            TextField {
                id: monthlyGross
                placeholderText: "0.00"
                validator: DoubleValidator { bottom: 0; decimals: 2 }
                onTextChanged: calculate(parseFloat(text) || 0, "monthly", false)
            }
            TextField {
                id: monthlyNet
                placeholderText: "0.00"
                validator: DoubleValidator { bottom: 0; decimals: 2 }
                onTextChanged: calculate(parseFloat(text) || 0, "monthly", true)
            }

            // Zeile: Jahr
            Text { text: "Pro Jahr:" }
            TextField {
                id: yearlyGross
                placeholderText: "0.00"
                validator: DoubleValidator { bottom: 0; decimals: 2 }
                onTextChanged: calculate(parseFloat(text) || 0, "yearly", false)
            }
            TextField {
                id: yearlyNet
                placeholderText: "0.00"
                validator: DoubleValidator { bottom: 0; decimals: 2 }
                onTextChanged: calculate(parseFloat(text) || 0, "yearly", true)
            }
        }

        Item { Layout.fillHeight: true } // Platzhalter nach unten

        Button {
            text: "Zurücksetzen"
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                isUpdating = true;
                hourlyGross.text = "";
                monthlyGross.text = "";
                yearlyGross.text = "";
                hourlyNet.text = "";
                monthlyNet.text = "";
                yearlyNet.text = "";
                isUpdating = false;
            }
        }
    }
}
