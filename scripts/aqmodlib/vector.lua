RADTODEG = 180.0 / 3.14159265359DEGTORAD = 3.14159265359 / 180.0local function vector_rotateRad(x, y, a)    local ox = x    local oy = y    x = math.cos(a)*ox - math.sin(a)*oy;    y = math.sin(a)*ox + math.cos(a)*oy;    return x, yendlocal function vector_rotateDeg(x, y, a)    return vector_rotateRad(x, y, DEGTORAD * a)endlocal function vector_fromRad(r, len)    if not len then len = 1 end    return vector_rotateRad(0, -len, r)endlocal function vector_fromDeg(r, len)    if not len then len = 1 end    return vector_rotateDeg(0, -len, r)endlocal function makeVector(fromx, fromy, tox, toy)    return tox - fromx, toy - fromyendlocal function vector_perpendicularLeft(x, y)    return -y, xendlocal function vector_perpendicularRight(x, y)    return y, -xendlocal function vector_getAngleDeg(vx, vy)    local vx, vy = vector_normalize(vx, vy)    return (math.atan2(vy, vx) * RADTODEG) + 90endreturn {    vector_rotateRad = vector_rotateRad,    vector_rotateDeg = vector_rotateDeg,    vector_fromRad = vector_fromRad,    vector_fromDeg = vector_fromDeg,    vector_perpendicularLeft = vector_perpendicularLeft,    vector_perpendicularRight = vector_perpendicularRight,    vector_getAngleDeg = vector_getAngleDeg,    makeVector = makeVector,}