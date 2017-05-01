# Relations
👬👫👭 A Swift script that makes graphs of your types

## Usage

```sh
$ relations --help

Usage:

    $ relations

Options:
    --typePredicate - Predicate for types evaluated with a [String: SourceKitRepresentable]. You must double-escape slashes, which usually means a \ turns into a \\\\
    --varPredicate - Predicate for properties evaluated with a [String: SourceKitRepresentable]. You must double-escape slashes, which usually means a \ turns into a \\\\
    --output [default: graph.dot] - Relative path for Graphviz .dot file

$ relations \
    --typePredicate "key.name ENDSWITH 'Wireframe'" \
    --varPredicate "key.typename MATCHES '.*Wireframe\\\\??$'" \
    --varPredicate "key.attributes == nil OR SUBQUERY(key.attributes, \$a, \$a.key.attribute == 'source.decl.attribute.weak').@count == 0" \
  && open -a Graphviz graph.dot
```

## Installation

Install using [Marathon](https://github.com/johnsundell/marathon):

```
$ git clone git@github.com:interstateone/Relations.git
$ marathon install Relations/Sources/Relations.swift
```

Install using the Swift Package Manager:

```
$ git clone git@github.com:interstateone/Relations.git
$ cd Relations
$ swift build -c release -Xswiftc -static-stdlib
$ cp -f .build/release/Relations /usr/local/bin/relations
```

