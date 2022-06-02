import ballerina/file;
import ballerina/lang.runtime;
import ballerina/io;
import ballerina/log;
import ballerina/mime;
import ballerina/test;
import ballerina/websubhub;
import websub_simplified_with_ballerina.hub as _;

function publishUpdates() returns error? {
    // `hub` is a configurable variable in the source.
    websubhub:PublisherClient pc = check new (hub);

    // Bug opened with `documentation` label.
    json payload = {
        "name": "Connectors",
        "actor": "amal",
        "kind": "bug",
        "action": "opened",
        "time": "2022-03-01T13:15:12",
        "title": "Filtering config is incorrect in doc",
        "version": "v2",
        "labels": ["filters", "documentation"],
        "severity": "high",
        "content": "$title, in the getting started doc."
    };
    websubhub:Acknowledgement|websubhub:UpdateMessageError res =
            pc->publishUpdate("http://projzone.com/so2w/Connectors/events/bugs.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(2);

    // Bug opened without `documentation` label.
    payload = {
        "name": "Connectors",
        "actor": "mary",
        "kind": "bug",
        "action": "opened",
        "time": "2022-03-01T14:25:01",
        "title": "Unclear error message",
        "version": "v1",
        "labels": ["diagnostics"],
        "severity": "medium",
        "content": "Unclear error message when an invalid config is provided."
    };
    res = pc->publishUpdate("http://projzone.com/so2w/Connectors/events/bugs.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(2);

    // Bug opened without `documentation` label.
    payload = {
        "name": "Connectors",
        "actor": "mary",
        "kind": "bug",
        "action": "opened",
        "time": "2022-03-01T16:10:31",
        "title": "Unclear setup steps",
        "version": "v1",
        "labels": [],
        "severity": "low",
        "content": "Unclear setup steps in documentation."
    };
    res = pc->publishUpdate("http://projzone.com/so2w/Connectors/events/bugs.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(2);

    // Bug closed.
    payload = {
        "name": "Connectors",
        "actor": "sunil",
        "kind": "bug",
        "action": "closed",
        "time": "2022-03-02T04:14:12",
        "title": "Authentication steps are incomplete",
        "version": "v2",
        "labels": ["documentation", "authn"],
        "severity": "high"
    };
    res = pc->publishUpdate("http://projzone.com/so2w/Connectors/events/bugs.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(2);

    // Improvement opened with `documentation` label.
    payload = {
        "name": "Connectors",
        "actor": "anne",
        "kind": "improvement",
        "action": "opened",
        "time": "2022-03-21T13:15:12",
        "title": "Add a diagram for filtering",
        "version": "v1",
        "labels": ["filters", "documentation"],
        "impact": "low",
        "content": "Will be easier to understand the flow with a diagram."
    };
    res = pc->publishUpdate("http://projzone.com/so2w/Connectors/events/improvements.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(2);

    // Improvement opened without `documentation` label.
    payload = {
        "name": "Connectors",
        "actor": "avi",
        "kind": "improvement",
        "action": "opened",
        "time": "2022-03-21T14:25:01",
        "title": "Improve error message",
        "version": "v1",
        "labels": ["diagnostics"],
        "impact": "low",
        "content": "Include information about failure IDs."
    };
    res = pc->publishUpdate("http://projzone.com/so2w/Connectors/events/improvements.json", payload, mime:APPLICATION_JSON);
    test:assertTrue(res is websubhub:Acknowledgement);
    runtime:sleep(2);
}

@test:BeforeSuite
function setup() returns error? {
    check publishUpdates();
    runtime:sleep(6);
}

@test:Config
function testProcessingEventNotifications() returns error? {
    string[][4] expectedContent = [
        ["Title", "Kind", "Affected Version", "Priority"],
        ["Filtering config is incorrect in doc", "bug", "v2", "1"],
        ["Add a diagram for filtering", "improvement", "v1", "3"]
    ];

    stream<string[], io:Error?> csvStream =
        check io:fileReadCsvAsStream("documentation_discussions.csv");

    string[][]? csvArray = check from string[] arr in csvStream select arr;

    if csvArray is () {
        test:assertFail("Expected the CSV file to be non-empty");
    }

    test:assertEquals(csvArray.length(), expectedContent.length());

    foreach string[4] expectedEntry in expectedContent {
        test:assertTrue(csvArray.indexOf(expectedEntry) !is (),
                        "missing an expected entry: " + expectedEntry.toString());
    }
}

// Remove the CSV file, to allow rerunning tests.
// Cannot do this in `BeforeSuite` since the file will be created at initialization.
@test:AfterSuite
function cleanUp() {
    file:Error? res = file:remove("documentation_discussions.csv");
    if res is file:Error {
        log:printError("Error removing CSV file", res);
    }
}
