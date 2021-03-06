import QtQuick 2.0
import QtTest 1.0
import QtWebKit 3.0
import QtWebKit.experimental 1.0
import "../common"

// FIXME: Added to Desktop tests because we want to have mouseClick() to open the <input> tag. We can move it back
// when TestCase starts supporting touch events, see https://bugreports.qt.nokia.com/browse/QTBUG-23083.
TestWebView {
    id: webView

    width: 400
    height: 400

    property bool selectFile
    property bool acceptMultiple: false

    experimental.filePicker: Item {
        Timer {
            running: true
            interval: 1
            onTriggered: {
                var selectedFiles = ["filename1", "filename2"]
                if (selectFile) {
                    if (acceptMultiple)
                        model.accept(selectedFiles)
                    else
                        model.accept("acceptedfilename");
                }
                else
                    model.reject();
            }
        }
    }

    SignalSpy {
        id: titleSpy
        target: webView
        signalName: "titleChanged"
    }

    TestCase {
        id: test
        name: "WebViewSingleFilePicker"
        when: windowShown

        function init() {
            webView.url = Qt.resolvedUrl("../common/singlefileupload.html")
            verify(webView.waitForLoadSucceeded())
            titleSpy.clear()
        }

        function openItemSelector() {
            mouseClick(webView, 15, 15, Qt.LeftButton)
        }

        function test_accept() {
            webView.selectFile = true;
            openItemSelector()
            titleSpy.wait()
            compare(webView.title, "acceptedfilename")
        }

        function test_multiple() {
            webView.selectFile = true;
            webView.acceptMultiple = true;
            openItemSelector()
            titleSpy.wait()
            compare(webView.title, "filename1")
        }

        function test_reject() {
            var oldTitle = webView.title
            webView.selectFile = false;
            openItemSelector()
            compare(webView.title, oldTitle)
        }
    }
}
