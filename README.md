# 7.2 ProjZone Webhooks

## Problem Statement

The requirement is similar to Problem 7.1, with the following exceptions.

- For convenience when working with webhooks, the **ProjZone** team has pushed a module `projzone/webhook` to Ballerina Central. Use this module instead of the generic WebSub subscriber.
- Add **only bug and improvement discussions** to the CSV file. Set up the listener/services to receive updates only for bugs and improvements.

## Constraints

Same as those for Problem 7.1.

## Definition

- Use the custom webhook listener from `projzone/webhook`, instead of WebSub.
- Use `so2w` as the `orgName` and `Connectors` as the `projectName` when initializing the listener.
- Use the configurable `secret`, `hub`, and `port` variables as arguments to `new` when initializing the listener.

## Example 1

**Input**

The following three notifications.

1. A bug discussion is opened with the documentation label.

```json
{
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
}
```

1. A bug discussion is opened without the documentation label.

```json
{
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
}
```

1. A feature request discussion is opened with the documentation label.

```json
{
    "name": "Connectors",
    "actor": "manny",
    "kind": "feature request",
    "action": "opened",
    "time": "2022-03-21T22:15:12",
    "title": "Add left navigation for docs",
    "version": "v1",
    "labels": ["filters", "documentation"],
    "content": "Will be easier when getting started."
}
```

**Output**

The CSV file should contain the following (entries for discussions don't have to be in the same order as the notifications).

```csv
Title,Kind,Affected Version,Priority
Filtering config is incorrect in doc,bug,v2,1
```

## Test Environment

A WebSub hub that accepts subscription requests for `ProjZone` is expected to be up and running.

An implementation of a simple hub service is provided in the `hub` module. The default URL is `http://localhost:9090/hub`.

Running `bal test` will handle starting up the hub service before the subscriber service starts up.

## Hints

- Multiple services can be attached to the same listener.
- The `projhub/webhook:Listener` decides what events to subscribe for depending on the attached service. E.g., if only a `webhook:BugDiscussionService` service is attached, it will subscribe to only bug discussion notifications.
- The [`ballerina/io`](https://lib.ballerina.io/ballerina/io/1.2.1) module can be used to create and write to CSV files.
- [Reading and writing CSV](https://ballerina.io/learn/by-example/io-csv.html)
- [API documentation of `projzone/webhook`](https://lib.ballerina.io/projzone/webhook/0.1.0)
