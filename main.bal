import ballerina/io;
import ballerina/file;
import projzone/webhook;

configurable string hub = "http://localhost:9090/hub";
configurable string secret = "djflgs";
configurable string topic = "http://projzone.com/so2w/Connectors/events/all.json";
configurable int port = 8080;

listener webhook:Listener ln = new (port, "so2w", "Connectors", secret, hub);
service webhook:BugDiscussionService on ln {

    remote function onDiscussionClosed(webhook:BugDiscussionEvent event) {
        //do nothing
    }

    remote function onDiscussionLabeled(webhook:BugDiscussionLabeledEvent event) {
        if (isDocumentation(event.labels)){
            writeToFile([[event.title, event.kind, event.'version, self.getPriority(event.severity).toString()]]);
        }
    }

    remote function onDiscussionCommented(webhook:BugDiscussionOpenedOrCommentedEvent event) {
        //do nothing
    }

    remote function onDiscussionOpened(webhook:BugDiscussionOpenedOrCommentedEvent event) {
        if (isDocumentation(event.labels)){
            writeToFile([[event.title, event.kind, event.'version, self.getPriority(event.severity).toString()]]);
        }
    }

    function getPriority(webhook:Severity severity) returns int {
        match severity {
            webhook:HIGH => {return 1;}
            webhook:MEDIUM => {return 2;}
            webhook:LOW => {return 3;}
            _ => {panic error("");}
        }
    }
}

service webhook:ImprovementDiscussionService on ln {
    

    remote function onDiscussionClosed(webhook:ImprovementDiscussionEvent event) {
        //do nothing
    }

    remote function onDiscussionCommented(webhook:ImprovementDiscussionOpenedOrCommentedEvent event) {
       //do nothing
    }

    remote function onDiscussionLabeled(webhook:ImprovementDiscussionLabeledEvent event) {
        if (isDocumentation(event.labels)){
            writeToFile([[event.title, event.kind, event.'version, self.getPriority(event.impact).toString()]]);
        }
    }

    remote function onDiscussionOpened(webhook:ImprovementDiscussionOpenedOrCommentedEvent event) {
        if (isDocumentation(event.labels)){
            writeToFile([[event.title, event.kind, event.'version, self.getPriority(event.impact).toString()]]);
        }
    }

    function getPriority(webhook:Impact impact) returns int {
        match impact {
            webhook:SIGNIFICANT => {return 2;}
            webhook:LOW => {return 3;}
            _ => {panic error("");}
        }
    }
}

function isDocumentation(string[] labels) returns boolean{
    return labels.indexOf("documentation") is int;
}

function writeToFile(string [][] content){
    string fileName = "./documentation_discussions.csv";
    do {
        boolean|file:Error test = check file:test(fileName, file:EXISTS);
        if (test is file:Error || !test){
            _ = check io:fileWriteCsv(fileName, [["Title", "Kind", "Affected Version", "Priority"]], io:APPEND);
        }

        _ = check io:fileWriteCsv(fileName, content, io:APPEND);
    } on fail var e {
        io:println(e);
    }
}