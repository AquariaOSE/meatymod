if not v then v = {} endfunction init(me)    local c = node_getContent(me)    local node = node_getNearestNode(me, c)    node_setActive(node, false)endfunction update(me, dt)endfunction songNote(me, note)endfunction songNoteDone(me, note, done)end