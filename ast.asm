
section .data
    delim db " ", 0

section .bss
    root resd 1

section .text

extern calloc
extern check_atoi
extern print_tree_inorder
extern print_tree_preorder
extern evaluate_tree

global create_tree
global iocla_atoi

iocla_atoi: 

    mov edx, [ebp + 8]			; savlarea string-ului care
    mov edi, [edx]				; va fi convertit in numar

    mov ecx, 0					; contor caractere numerice
    mov eax, 0					; eax retine rezultatul final
    mov ebx, 0

    mov al, byte [edi]			

    cmp al, 0x2d				; verificare daca numarul este
    je is_signed				; pozitv sau negativ

    push 0

cycle:
	mov al, byte [edi + ecx]	; parcurgere a string-ului byte cu byte
    cmp al,0
    je end

    push ecx
    jmp multiply				; inmultire a numarului cu 10
multiplied: 
	pop ecx

    sub al, 0x30				; convertire caracter in numar
    add ebx, eax

    inc ecx
    jmp cycle

end:
	pop ecx
	cmp ecx, 1
	je set_signed_number		
is_set:	
	mov eax, ebx				; salvarea rezultatului final in eax
    ret

multiply:						; inmultire prin adaugarea
	mov ecx, 9					; repetata a numarului
	mov edx, ebx

addition:						
	add ebx, edx
	loop addition

	jmp multiplied

is_signed:						; numar cu semn
	push 1
	inc edi						; se incrementeaza adresa string-ului
	jmp cycle					; pentru a trece peste caracterul "-"

set_signed_number:				
	mov ecx, 0		
	sub ecx, ebx				; -numar = 0 - numar
	mov ebx, ecx
	jmp is_set

get_data:
	push ebp
	mov ebp,esp

	mov ecx, 0
	xor edx, edx
search:	
    mov dl , byte [edi + ecx]  	; parcurgerea sirului de caractere din input	    							; byte cu byte
    inc ecx
    push edx					; inserarea caracterelor valide in stiva

    cmp dl, 0					; sirul de caractere a fost examinat
    je continue					; in intregime

    cmp dl, 0x20				; caracterul extras este chiar delimitatorul
    jne search
continue:
    pop edx

    dec ecx
    push ecx

    push 8						; alocare memorie pentru char* data
    push 1
    call calloc
    add esp, 8

    pop ecx

    add edi, ecx				; eliminarea caracterelor extrase din input
    add edi, 1					; eliminarea delimitatorului

create_string:					; construire char* data
    pop edx						; extragerea caracterelor salvate in stiva
    mov byte [eax + ecx - 1], dl
    loop create_string

    leave
	ret

create_new_node:
	push ebp
	mov ebp,esp

	call get_data				; create char* data
	push eax 					; eax retine adresa catre char* data

	push 4
    push 3
    call calloc					; alocare memorie pentru un nod
    add esp, 8

    mov edx, eax
    pop eax
    mov  [edx], eax 			; linkare node <-> char* data
    mov eax, edx				; eax va intoarce adresa nodului creat

    leave
	ret

recursive_left:
	mov cl, byte [edi]			; verificare daca input-ul a fost deja
    cmp cl, 0					; parcurs in intregime => programul se opreste
    je final

	mov edx, [esp]				; extragerea adresei nodului precedent
	add edx, 4					; adresa unde va fi stocat nodul stang
	push edx

	call create_new_node		; crearea nodului(stang) care va fi adaugat

	pop edx						; adresa la care se va adauga noul nod
	mov [edx], eax 				; linkare node <-> left_node

	mov edx, [eax]				; extragere valoare char* data 
    mov edx, [edx]				; din nodul curent

    cmp edx, 0x2d				; verificare daca continutul de la char* data
    je is_operand				; este un numar sau operand

    cmp edx, 0x2f
    je is_operand

    cmp edx, 0x2a
    je is_operand

    cmp edx, 0x2b
    je is_operand

    jmp is_number

recursive_right:
	mov cl, byte [edi]			; verificare daca input-ul a fost deja
    cmp cl, 0					; parcurs in intregime => programul se opreste
    je final

	mov edx, dword [esp]		; extragerea adresei nodului precedent
	add edx, 8					; adresa unde va fi stocat nodul stang
	push edx

	call create_new_node		; crearea nodului(drept) care va fi adaugat

	pop edx						; adresa la care se va adauga noul nod
back:
	mov ecx, [edx]				; verificare daca adresa este valida
	cmp ecx, 0 					; (nu se afla deja alt nod linkat)
	jne is_full

	mov [edx], eax 				; linkare node <-> right_node

	mov edx, dword [eax]		; extragere valoare char* data 
    mov edx, dword [edx]		; din nodul curent

    cmp edx, 0x2d				; verificare daca continutul de la char* data
    je is_operand				; este un numar sau operand

    cmp edx, 0x2f
    je is_operand

    cmp edx, 0x2a
    je is_operand

    cmp edx, 0x2b
    je is_operand

    jmp is_number

is_operand:						; continutul de la char* data este un operand
	push eax 					; se retine in stiva adresa nodului curent
	jmp recursive_left			; se continua recursivitatea pe nodul stang

is_number:  					; continutul de la char* data este un numar
	jmp recursive_right			; se continua recursivitatea pe nodul drept

is_full:						; adresa nodului drept este deja ocupata
	pop edx						; se "urca" in arbore pe ramura dreapta
	add edx, 8
	jmp back

create_tree:

    enter 0, 0
    xor eax, eax

    mov edi, [ebp + 8] 			; edi retine string-ul de input din stiva

    call create_new_node		; creare radacina arborelui
    mov [root], eax

    push eax
    jmp recursive_left			

final:
    mov eax, [root]				; eax retine adresa nodului radacina

    leave
    ret
