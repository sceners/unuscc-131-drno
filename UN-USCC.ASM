; USCC v1.31 Unpacker
; Coded by dR.No // Delirium Tremens

model tiny
.code
.386

org 100h
Begin:
        mov     dx,offset Msg
        call    write
        mov     si,81h
        lodsb
        cmp     al,0Dh
        jne     FileOk
        mov     dx,offset Usage
        jmp     short write

FileOk:
        push    si si
        pop     cx di

@Str:
        mov     al,[di]
        cmp     al,0Dh
        je      _EndStr
        inc     di
        loop    @Str

_EndStr:
        mov     Word Ptr [di],2400h
        mov     dx,si
        mov     ax,3D02h
        int     21h
        jnc     NoErr
        mov     dx,offset not_found
        jmp     short Write

NoErr:
        xchg    bx,ax
        mov     dx,offset Process
        call    write
        mov     dx,si
        int     21h
        xor     cx,cx
        xor     dx,dx
        mov     ax,4200h
        int     21h
        mov     ah,3Fh
        mov     dx,offset Buf
        mov     cx,-1
        int     21h

        mov     bp,offset Buf
        mov     di,bp
        add     bp,ax
        cmp     DWord Ptr [bp-0B7h],3000AFB9h
        je      CryptOk
        mov     dx,offset NotCrypt
Write:
        mov     ah,09
        int     21h
        ret

CryptOk:
        mov     bp,ax
        mov     cx,bp
        push    cx

        push    dx dx

        mov     ah,3Eh
        int     21h

        pop     si

        pusha

        add     di,bp
        mov     cx,0AFh
        sub     di,cx

@PreDecode1:
        xor     [di],cl
        inc     di
        loop    @PreDecode1

        mov     cx,2Ch
        mov     bl,Byte Ptr [di-4Dh]

@PreDecode2:
        xor     [di-02Bh],bl
        inc     di
        loop @PreDecode2

        push    dx
        xor     dx,dx
        mov     bx,4
        div     bx
        mov     cx,ax
        pop     dx

        mov     di,offset Buf
        push    di
        add     di,bp
        mov     ax,[di-15h]
        mov     bl,[di-0Fh]
        pop     di
        mov     Word Ptr [di],ax
        mov     Byte Ptr [di+2],bl
        mov     eax,12312320h
@Decode:
        xor     [di+3],eax
        add     di,4
        loop    @Decode


        popa

        mov     dx,offset _Out
        mov     ax,3C02h
        xor     cx,cx
        int     21h

        xchg    bx,ax

        pop     dx
        pop     cx
        sub     cx,186
        mov     ah,40h
        int     21h

        mov     ah,3Eh
        int     21h
        mov     dx,offset Oki
        jmp     write
Msg             db              0dh,0ah,'USCC v1.31 Unpacker Coded by dR.No // ViP // DTg ',0dh,0ah,24h
Usage           db              0dh,0ah,'Usage: UN-USCC <CRYPTFiLE>',0dh,0ah,24h
Not_found       db              'File not found',0dh,0ah,24h
NotCrypt        db              0dh,0ah,'File is not crypted with USCC v1.31',0dh,0ah,24h
Process         db              'Unpacking the file: $'
Oki             db              '... completed!',0dh,0ah,24h
_Out            db              'UNPACKED.COM',0
Buf:
End Begin