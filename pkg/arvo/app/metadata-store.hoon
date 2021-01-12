::  metadata-store [landscape]:
::
::  data store for application metadata and mappings
::  between groups and resources within applications
::
::  group-paths are expected to be an existing group path
::  resources are expected to correspond to existing app paths
::
::  note: when scrying for metadata, to make the arguments safe in paths,
::  encode group-path and app-path using (scot %t (spat group-path))
::
::  +watch paths:
::  /all                                  associations + updates
::  /updates                              just updates
::  /app-name/%app-name                   specific app's associations + updates
::
::  +peek paths:
::  /associations                                  all associations
::  /group-indices                                 all group indices
::  /app-indices                                   all app indices
::  /resource-indices                              all resource indices
::  /metadata/%group-path/%app-name/%app-path      specific metadatum
::  /app-name/%app-name                            associations for app
::  /group/%group-path                             associations for group
::
/-  *metadata-store, *metadata-hook
/+  *metadata-json, default-agent, verb, dbug, resource, *migrate
|%
+$  card  card:agent:gall
+$  base-state-0
  $:  associations=associations-0
      group-indices=(jug group-path md-resource)
      app-indices=(jug app-name [group-path app-path])
      resource-indices=(jug md-resource group-path)
  ==
::
+$  associations-0  (map [group-path md-resource] metadata-0)
::
+$  metadata-0
  $:  title=@t
      description=@t
      color=@ux
      date-created=@da
      creator=@p
  ==
::
+$  md-resource-1   [=app-name =app-path]
::
+$  associations-1  (map [group-path md-resource-1] metadata)
::
+$  base-state-1
  $:  associations=associations-1
      group-indices=(jug group-path md-resource-1)
      app-indices=(jug app-name [group-path app-path])
      resource-indices=(jug md-resource-1 group-path)
  ==
::
+$  cached-indices
  $:  group-indices=(jug resource md-resource)
      app-indices=(jug app-name [group=resource =resource])
      resource-indices=(jug md-resource resource)
  ==
::
+$  base-state-2
  $:  =associations
      ~
  ==
::
+$  state-0   [%0 base-state-0]
+$  state-1   [%1 base-state-0]
+$  state-2   [%2 base-state-0]
+$  state-3   [%3 base-state-1]
+$  state-4   [%4 base-state-1]
+$  state-5   [%5 base-state-1]
+$  state-6   [%6 base-state-1]
+$  state-7   [%7 base-state-2]
+$  versioned-state
  $%  state-0
      state-1
      state-2
      state-3
      state-4
      state-5
      state-6
      state-7
  ==
::
+$  inflated-state
  $:  state-7
      cached-indices
  ==
--
::
=|  inflated-state
=*  state  -
%+  verb  |
%-  agent:dbug
^-  agent:gall
=<
  |_  =bowl:gall
  +*  this  .
      mc    ~(. +> bowl)
      def   ~(. (default-agent this %|) bowl)
  ::
  ++  on-init  on-init:def
  ++  on-save  !>(-.state)
  ++  on-load
    |=  =vase
    ^-  (quip card _this)
    =^  cards  state
      (on-load:mc vase)
    [cards this]
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?>  (team:title our.bowl src.bowl)
    =^  cards  state
      ?+  mark  (on-poke:def mark vase)
          %metadata-action
        (poke-metadata-action:mc !<(metadata-action vase))
      ::
          %import
        (poke-import:mc q.vase)
      ==
    [cards this]
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    ?>  (team:title our.bowl src.bowl)
    |^
    =/  cards=(list card)
      ?+  path  (on-watch:def path)
          [%all ~]
        (give %metadata-update !>([%associations associations]))
      ::
          [%updates ~]
        ~
      ::
          [%app-name @ ~]
        =/  =app-name  i.t.path
        =/  app-indices  (metadata-for-app:mc app-name)
        (give %metadata-update !>([%associations app-indices]))
      ==
    [cards this]
    ::
    ++  give
      |=  =cage
      ^-  (list card)
      [%give %fact ~ cage]~
    --
  ::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?+  path  (on-peek:def path)
        [%y %group-indices ~]     ``noun+!>(group-indices)
        [%y %app-indices ~]       ``noun+!>(app-indices)
        [%y %resource-indices ~]  ``noun+!>(resource-indices)
        [%x %associations ~]      ``noun+!>(associations)
        [%x %app-name @ ~]
      =/  =app-name  i.t.t.path
      ``noun+!>((metadata-for-app:mc app-name))
    ::
        [%x %group *]
      =/  group=resource  (de-path:resource t.t.path)
      ``noun+!>((metadata-for-group:mc group))
    ::
        [%x %metadata @ @ @ ~]
      =/  group=resource  (de-path:resource (stab (slav %t i.t.t.path)))
      =/  =md-resource  [`term`i.t.t.t.path (de-path:resource (stab (slav %t i.t.t.t.t.path)))]
      ``noun+!>((~(get by associations) [group md-resource]))
    ::
        [%x %resource @ *]
      =/  app=term        i.t.t.path
      =/  rid=resource    (de-path:resource t.t.t.path)
      ``noun+!>((~(get by resource-indices) app rid))
    ::
        [%x %export ~]
      ``noun+!>(-.state)
    ==
  ::
  ++  on-leave  on-leave:def
  ++  on-agent  on-agent:def
  ++  on-arvo   on-arvo:def
  ++  on-fail   on-fail:def
  --
::
|_  =bowl:gall
::
++  on-load
  |=  =vase
  ^-  (quip card _state)
  =/  old  !<(versioned-state vase)
  =|  cards=(list card)
  |^
  ?:  ?=(%7 -.old)
    :-  cards
    %_  state
         associations
       associations.old
      ::
         resource-indices
       (rebuild-resource-indices associations.old)
      ::
        app-indices
      (rebuild-app-indices associations.old)
      ::
        group-indices
      (rebuild-group-indices associations.old)
    ==
  ?:  ?=(%6 -.old)
    =/  old-assoc=associations-1
      (migrate-app-to-graph-store %chat associations.old)
    $(old [%7 (associations-1-to-2 old-assoc) ~])
  ::
  ?:  ?=(%5 -.old)
    =/  associations=associations-1
      (migrate-app-to-graph-store %publish associations.old)
    %_    $
      -.old  %6
      associations.old  associations
    ==
  ::  pre-breach, can safely throw away
  $(old *state-7)
  ++  associations-1-to-2
    |=  assoc=*
    *^associations
  ::
  ++  rebuild-resource-indices
    |=  =^associations
    %-  ~(gas ju *(jug md-resource resource))
    %+  turn  ~(tap in ~(key by associations))
    |=  [g=resource r=md-resource]
    ^-  [md-resource resource]
    [r g] 
  ::
  ++  rebuild-group-indices
    |=  =^associations 
    %-  ~(gas ju *(jug resource md-resource))
    ~(tap in ~(key by associations))
  ::
  ++  rebuild-app-indices
    |=  =^associations
    %-  ~(gas ju *(jug app-name [group=resource resource]))
    %+  turn  ~(tap in ~(key by associations))
    |=  [g=resource r=md-resource]
    ^-  [app-name [resource resource]]
    [app-name.r [g resource.r]]
  ::
  ++  migrate-app-to-graph-store
    |=  [app=@tas associations=associations-1]
    ^-  associations-1
    %-  malt
    %+  turn  ~(tap by associations)
    |=  [[=group-path md-resource=md-resource-1] m=metadata]
    ^-  [[^group-path md-resource-1] metadata]
    ~!  md-resource
    ?.  =(app-name.md-resource app)  
      [[group-path md-resource] m]
    =/  new-app-path=path
      ?.  ?=([@ @ ~] app-path.md-resource)
        app-path.md-resource
      ship+app-path.md-resource
    [[group-path [%graph new-app-path]] m(module app)]
  --
++  poke-metadata-action
  |=  act=metadata-action
  ^-  (quip card _state)
  ?>  (team:title our.bowl src.bowl)
  ?-  -.act
      %add     (handle-add group.act resource.act metadata.act)
      %remove  (handle-remove group.act resource.act)
  ==
::
++  poke-import
  |=  arc=*
  ^-  (quip card _state)
  |^
  (on-load !>([%7 (remake-metadata ;;(tree-metadata +.arc))]))
  ::
  +$  tree-metadata
    $:  associations=(tree [[resource md-resource] metadata])
        ~
    ==
  ::
  ++  remake-metadata
    |=  tm=tree-metadata
    ^-  base-state-2
    :*  (remake-map associations.tm)
        ~
    ==
  --
::
++  handle-add
  |=  [group=resource =md-resource =metadata]
  ^-  (quip card _state)
  :-  %+  send-diff  app-name.md-resource
      ?:  (~(has by resource-indices) md-resource)
        [%update-metadata group md-resource metadata]
      [%add group md-resource metadata]
  %=  state
      associations
    (~(put by associations) [group md-resource] metadata)
  ::
      group-indices
    (~(put ju group-indices) group md-resource)
  ::
      app-indices
    %+  ~(put ju app-indices)
      app-name.md-resource
    [group resource.md-resource]
  ::
      resource-indices
    (~(put ju resource-indices) md-resource group)
  ==
::
++  handle-remove
  |=  [group=resource =md-resource]
  ^-  (quip card _state)
  :-  (send-diff app-name.md-resource [%remove group md-resource])
  %=  state
      associations
    (~(del by associations) [group md-resource])
  ::
      group-indices
    (~(del ju group-indices) group md-resource)
  ::
      app-indices
    %+  ~(del ju app-indices)
      app-name.md-resource
    [group resource.md-resource]
  ::
      resource-indices
    (~(del ju resource-indices) md-resource group)
  ==
::
++  metadata-for-app
  |=  =app-name
  ^-  ^associations
  %-  ~(gas by *^associations)
  %+  turn  ~(tap in (~(gut by app-indices) app-name ~))
  |=  [group=resource rid=resource]
  :-  [group [app-name rid]]
  (~(got by associations) [group [app-name rid]])
::
++  metadata-for-group
  |=  group=resource
  ^-  ^associations
  %-  ~(gas by *^associations)
  %+  turn  ~(tap in (~(gut by group-indices) group ~))
  |=  =md-resource
  :-  [group md-resource]
  (~(got by associations) [group md-resource])
::
++  send-diff
  |=  [=app-name upd=metadata-update]
  ^-  (list card)
  |^
  %-  zing
  :~  (update-subscribers /all upd)
      (update-subscribers /updates upd)
      (update-subscribers [%app-name app-name ~] upd)
  ==
  ::
  ++  update-subscribers
    |=  [pax=path upd=metadata-update]
    ^-  (list card)
    [%give %fact ~[pax] %metadata-update !>(upd)]~
  --
--
