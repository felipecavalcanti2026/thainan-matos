"""Recorte ancorado na borda, em Python puro. Contorna o sips, que so corta centralizado."""
import zlib, struct, subprocess, pathlib, sys

def png_ler(p):
    d = pathlib.Path(p).read_bytes(); i = 8; idat = b''
    while i < len(d):
        ln = int.from_bytes(d[i:i+4],'big'); t = d[i+4:i+8]
        if t == b'IHDR': w,h,bd,ct = struct.unpack(">IIBB", d[i+8:i+18])
        elif t == b'IDAT': idat += d[i+8:i+8+ln]
        elif t == b'IEND': break
        i += 12+ln
    assert bd == 8, f"bit depth {bd} nao suportado"
    bpp = {0:1,2:3,3:1,4:2,6:4}[ct]
    raw = zlib.decompress(idat); linhas = []
    ant = bytes(w*bpp); pos = 0
    for _ in range(h):
        f = raw[pos]; pos += 1
        lin = bytearray(raw[pos:pos+w*bpp]); pos += w*bpp
        if f == 0: pass
        elif f == 2:
            for x in range(len(lin)): lin[x] = (lin[x]+ant[x]) & 255
        elif f == 1:
            for x in range(bpp,len(lin)): lin[x] = (lin[x]+lin[x-bpp]) & 255
        elif f == 3:
            for x in range(len(lin)):
                a = lin[x-bpp] if x >= bpp else 0
                lin[x] = (lin[x]+((a+ant[x])>>1)) & 255
        else:
            for x in range(len(lin)):
                a = lin[x-bpp] if x >= bpp else 0
                c = ant[x-bpp] if x >= bpp else 0
                b = ant[x]
                pa,pb,pc = abs(b-c),abs(a-c),abs(a+b-2*c)
                pr = a if (pa<=pb and pa<=pc) else (b if pb<=pc else c)
                lin[x] = (lin[x]+pr) & 255
        linhas.append(bytes(lin)); ant = lin
    return w,h,bpp,linhas

def png_escrever(p,w,h,bpp,linhas):
    ct = {1:0,2:4,3:2,4:6}[bpp]
    raw = b''.join(b'\x00'+l for l in linhas)
    def ch(t,d):
        c = t+d; return struct.pack(">I",len(d))+c+struct.pack(">I",zlib.crc32(c)&0xffffffff)
    pathlib.Path(p).write_bytes(b'\x89PNG\r\n\x1a\n'
        + ch(b'IHDR',struct.pack(">IIBBBBB",w,h,8,ct,0,0,0))
        + ch(b'IDAT',zlib.compress(raw,6)) + ch(b'IEND',b''))

def recortar(origem, destino, corte_topo=0, corte_base=0, ratio_alvo=None, qualidade='90'):
    """corte_topo/base em fracao da altura. ratio_alvo = largura/altura final."""
    tmp_in  = '/tmp/_rec_in.png'; tmp_out = '/tmp/_rec_out.png'
    subprocess.run(['sips','-s','format','png',origem,'--out',tmp_in],capture_output=True,check=True)
    w,h,bpp,L = png_ler(tmp_in)
    y0 = round(h*corte_topo); y1 = h - round(h*corte_base)
    L = L[y0:y1]; nh = len(L)
    nw = w
    if ratio_alvo:
        alvo = round(nh*ratio_alvo)
        if alvo < w:                                   # estreita simetricamente
            corta = w-alvo; esq = corta//2
            L = [l[esq*bpp:(esq+alvo)*bpp] for l in L]; nw = alvo
        elif alvo > w:                                 # encurta pelo centro
            nova_h = round(w/ratio_alvo); sobra = nh-nova_h
            L = L[sobra//2: sobra//2+nova_h]; nh = nova_h
    png_escrever(tmp_out,nw,nh,bpp,L)
    subprocess.run(['sips','-s','format','jpeg','-s','formatOptions',qualidade,
                    tmp_out,'--out',destino],capture_output=True,check=True)
    return w,h,nw,nh
