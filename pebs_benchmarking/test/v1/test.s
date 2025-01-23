
spec_gcc_o0.out：     文件格式 elf64-x86-64


Disassembly of section .init:

0000000000001000 <_init>:
    1000:	f3 0f 1e fa          	endbr64 
    1004:	48 83 ec 08          	sub    $0x8,%rsp
    1008:	48 8b 05 d9 2f 00 00 	mov    0x2fd9(%rip),%rax        # 3fe8 <__gmon_start__@Base>
    100f:	48 85 c0             	test   %rax,%rax
    1012:	74 02                	je     1016 <_init+0x16>
    1014:	ff d0                	call   *%rax
    1016:	48 83 c4 08          	add    $0x8,%rsp
    101a:	c3                   	ret    

Disassembly of section .plt:

0000000000001020 <.plt>:
    1020:	ff 35 6a 2f 00 00    	push   0x2f6a(%rip)        # 3f90 <_GLOBAL_OFFSET_TABLE_+0x8>
    1026:	f2 ff 25 6b 2f 00 00 	bnd jmp *0x2f6b(%rip)        # 3f98 <_GLOBAL_OFFSET_TABLE_+0x10>
    102d:	0f 1f 00             	nopl   (%rax)
    1030:	f3 0f 1e fa          	endbr64 
    1034:	68 00 00 00 00       	push   $0x0
    1039:	f2 e9 e1 ff ff ff    	bnd jmp 1020 <_init+0x20>
    103f:	90                   	nop
    1040:	f3 0f 1e fa          	endbr64 
    1044:	68 01 00 00 00       	push   $0x1
    1049:	f2 e9 d1 ff ff ff    	bnd jmp 1020 <_init+0x20>
    104f:	90                   	nop
    1050:	f3 0f 1e fa          	endbr64 
    1054:	68 02 00 00 00       	push   $0x2
    1059:	f2 e9 c1 ff ff ff    	bnd jmp 1020 <_init+0x20>
    105f:	90                   	nop
    1060:	f3 0f 1e fa          	endbr64 
    1064:	68 03 00 00 00       	push   $0x3
    1069:	f2 e9 b1 ff ff ff    	bnd jmp 1020 <_init+0x20>
    106f:	90                   	nop
    1070:	f3 0f 1e fa          	endbr64 
    1074:	68 04 00 00 00       	push   $0x4
    1079:	f2 e9 a1 ff ff ff    	bnd jmp 1020 <_init+0x20>
    107f:	90                   	nop
    1080:	f3 0f 1e fa          	endbr64 
    1084:	68 05 00 00 00       	push   $0x5
    1089:	f2 e9 91 ff ff ff    	bnd jmp 1020 <_init+0x20>
    108f:	90                   	nop
    1090:	f3 0f 1e fa          	endbr64 
    1094:	68 06 00 00 00       	push   $0x6
    1099:	f2 e9 81 ff ff ff    	bnd jmp 1020 <_init+0x20>
    109f:	90                   	nop

Disassembly of section .plt.got:

00000000000010a0 <__cxa_finalize@plt>:
    10a0:	f3 0f 1e fa          	endbr64 
    10a4:	f2 ff 25 4d 2f 00 00 	bnd jmp *0x2f4d(%rip)        # 3ff8 <__cxa_finalize@GLIBC_2.2.5>
    10ab:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

Disassembly of section .plt.sec:

00000000000010b0 <putchar@plt>:
    10b0:	f3 0f 1e fa          	endbr64 
    10b4:	f2 ff 25 e5 2e 00 00 	bnd jmp *0x2ee5(%rip)        # 3fa0 <putchar@GLIBC_2.2.5>
    10bb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

00000000000010c0 <getpid@plt>:
    10c0:	f3 0f 1e fa          	endbr64 
    10c4:	f2 ff 25 dd 2e 00 00 	bnd jmp *0x2edd(%rip)        # 3fa8 <getpid@GLIBC_2.2.5>
    10cb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

00000000000010d0 <strlen@plt>:
    10d0:	f3 0f 1e fa          	endbr64 
    10d4:	f2 ff 25 d5 2e 00 00 	bnd jmp *0x2ed5(%rip)        # 3fb0 <strlen@GLIBC_2.2.5>
    10db:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

00000000000010e0 <__stack_chk_fail@plt>:
    10e0:	f3 0f 1e fa          	endbr64 
    10e4:	f2 ff 25 cd 2e 00 00 	bnd jmp *0x2ecd(%rip)        # 3fb8 <__stack_chk_fail@GLIBC_2.4>
    10eb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

00000000000010f0 <printf@plt>:
    10f0:	f3 0f 1e fa          	endbr64 
    10f4:	f2 ff 25 c5 2e 00 00 	bnd jmp *0x2ec5(%rip)        # 3fc0 <printf@GLIBC_2.2.5>
    10fb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000000001100 <getchar@plt>:
    1100:	f3 0f 1e fa          	endbr64 
    1104:	f2 ff 25 bd 2e 00 00 	bnd jmp *0x2ebd(%rip)        # 3fc8 <getchar@GLIBC_2.2.5>
    110b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000000001110 <__isoc99_sscanf@plt>:
    1110:	f3 0f 1e fa          	endbr64 
    1114:	f2 ff 25 b5 2e 00 00 	bnd jmp *0x2eb5(%rip)        # 3fd0 <__isoc99_sscanf@GLIBC_2.7>
    111b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

Disassembly of section .text:

0000000000001120 <_start>:
    1120:	f3 0f 1e fa          	endbr64 
    1124:	31 ed                	xor    %ebp,%ebp
    1126:	49 89 d1             	mov    %rdx,%r9
    1129:	5e                   	pop    %rsi
    112a:	48 89 e2             	mov    %rsp,%rdx
    112d:	48 83 e4 f0          	and    $0xfffffffffffffff0,%rsp
    1131:	50                   	push   %rax
    1132:	54                   	push   %rsp
    1133:	45 31 c0             	xor    %r8d,%r8d
    1136:	31 c9                	xor    %ecx,%ecx
    1138:	48 8d 3d 44 05 00 00 	lea    0x544(%rip),%rdi        # 1683 <main>
    113f:	ff 15 93 2e 00 00    	call   *0x2e93(%rip)        # 3fd8 <__libc_start_main@GLIBC_2.34>
    1145:	f4                   	hlt    
    1146:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    114d:	00 00 00 

0000000000001150 <deregister_tm_clones>:
    1150:	48 8d 3d 91 2f 02 00 	lea    0x22f91(%rip),%rdi        # 240e8 <__TMC_END__>
    1157:	48 8d 05 8a 2f 02 00 	lea    0x22f8a(%rip),%rax        # 240e8 <__TMC_END__>
    115e:	48 39 f8             	cmp    %rdi,%rax
    1161:	74 15                	je     1178 <deregister_tm_clones+0x28>
    1163:	48 8b 05 76 2e 00 00 	mov    0x2e76(%rip),%rax        # 3fe0 <_ITM_deregisterTMCloneTable@Base>
    116a:	48 85 c0             	test   %rax,%rax
    116d:	74 09                	je     1178 <deregister_tm_clones+0x28>
    116f:	ff e0                	jmp    *%rax
    1171:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    1178:	c3                   	ret    
    1179:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000001180 <register_tm_clones>:
    1180:	48 8d 3d 61 2f 02 00 	lea    0x22f61(%rip),%rdi        # 240e8 <__TMC_END__>
    1187:	48 8d 35 5a 2f 02 00 	lea    0x22f5a(%rip),%rsi        # 240e8 <__TMC_END__>
    118e:	48 29 fe             	sub    %rdi,%rsi
    1191:	48 89 f0             	mov    %rsi,%rax
    1194:	48 c1 ee 3f          	shr    $0x3f,%rsi
    1198:	48 c1 f8 03          	sar    $0x3,%rax
    119c:	48 01 c6             	add    %rax,%rsi
    119f:	48 d1 fe             	sar    %rsi
    11a2:	74 14                	je     11b8 <register_tm_clones+0x38>
    11a4:	48 8b 05 45 2e 00 00 	mov    0x2e45(%rip),%rax        # 3ff0 <_ITM_registerTMCloneTable@Base>
    11ab:	48 85 c0             	test   %rax,%rax
    11ae:	74 08                	je     11b8 <register_tm_clones+0x38>
    11b0:	ff e0                	jmp    *%rax
    11b2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    11b8:	c3                   	ret    
    11b9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

00000000000011c0 <__do_global_dtors_aux>:
    11c0:	f3 0f 1e fa          	endbr64 
    11c4:	80 3d 35 2f 02 00 00 	cmpb   $0x0,0x22f35(%rip)        # 24100 <completed.0>
    11cb:	75 2b                	jne    11f8 <__do_global_dtors_aux+0x38>
    11cd:	55                   	push   %rbp
    11ce:	48 83 3d 22 2e 00 00 	cmpq   $0x0,0x2e22(%rip)        # 3ff8 <__cxa_finalize@GLIBC_2.2.5>
    11d5:	00 
    11d6:	48 89 e5             	mov    %rsp,%rbp
    11d9:	74 0c                	je     11e7 <__do_global_dtors_aux+0x27>
    11db:	48 8b 3d 26 2e 00 00 	mov    0x2e26(%rip),%rdi        # 4008 <__dso_handle>
    11e2:	e8 b9 fe ff ff       	call   10a0 <__cxa_finalize@plt>
    11e7:	e8 64 ff ff ff       	call   1150 <deregister_tm_clones>
    11ec:	c6 05 0d 2f 02 00 01 	movb   $0x1,0x22f0d(%rip)        # 24100 <completed.0>
    11f3:	5d                   	pop    %rbp
    11f4:	c3                   	ret    
    11f5:	0f 1f 00             	nopl   (%rax)
    11f8:	c3                   	ret    
    11f9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000001200 <frame_dummy>:
    1200:	f3 0f 1e fa          	endbr64 
    1204:	e9 77 ff ff ff       	jmp    1180 <register_tm_clones>

0000000000001209 <check>:
    1209:	f3 0f 1e fa          	endbr64 
    120d:	55                   	push   %rbp
    120e:	48 89 e5             	mov    %rsp,%rbp
    1211:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
    1215:	8b 05 05 2e 00 00    	mov    0x2e05(%rip),%eax        # 4020 <array1_size>
    121b:	48 98                	cltq   
    121d:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
    1221:	73 07                	jae    122a <check+0x21>
    1223:	b8 01 00 00 00       	mov    $0x1,%eax
    1228:	eb 05                	jmp    122f <check+0x26>
    122a:	b8 00 00 00 00       	mov    $0x0,%eax
    122f:	5d                   	pop    %rbp
    1230:	c3                   	ret    

0000000000001231 <victim_function>:
    1231:	f3 0f 1e fa          	endbr64 
    1235:	55                   	push   %rbp
    1236:	48 89 e5             	mov    %rsp,%rbp
    1239:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
    123d:	8b 05 dd 2d 00 00    	mov    0x2ddd(%rip),%eax        # 4020 <array1_size>
    1243:	48 98                	cltq   
    1245:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
    1249:	73 33                	jae    127e <victim_function+0x4d>
    124b:	48 8d 15 ee 2d 00 00 	lea    0x2dee(%rip),%rdx        # 4040 <array1>
    1252:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    1256:	48 01 d0             	add    %rdx,%rax
    1259:	0f b6 00             	movzbl (%rax),%eax
    125c:	0f b6 c0             	movzbl %al,%eax
    125f:	c1 e0 09             	shl    $0x9,%eax
    1262:	48 98                	cltq   
    1264:	48 8d 15 75 2e 00 00 	lea    0x2e75(%rip),%rdx        # 40e0 <array2>
    126b:	0f b6 14 10          	movzbl (%rax,%rdx,1),%edx
    126f:	0f b6 05 2a 2f 02 00 	movzbl 0x22f2a(%rip),%eax        # 241a0 <temp>
    1276:	21 d0                	and    %edx,%eax
    1278:	88 05 22 2f 02 00    	mov    %al,0x22f22(%rip)        # 241a0 <temp>
    127e:	90                   	nop
    127f:	5d                   	pop    %rbp
    1280:	c3                   	ret    

0000000000001281 <readMemoryByte>:
    1281:	f3 0f 1e fa          	endbr64 
    1285:	55                   	push   %rbp
    1286:	48 89 e5             	mov    %rsp,%rbp
    1289:	41 54                	push   %r12
    128b:	53                   	push   %rbx
    128c:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
    1290:	48 89 7d 88          	mov    %rdi,-0x78(%rbp)
    1294:	48 89 75 80          	mov    %rsi,-0x80(%rbp)
    1298:	48 89 95 78 ff ff ff 	mov    %rdx,-0x88(%rbp)
    129f:	64 48 8b 04 25 28 00 	mov    %fs:0x28,%rax
    12a6:	00 00 
    12a8:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
    12ac:	31 c0                	xor    %eax,%eax
    12ae:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%rbp)
    12b5:	c7 45 a0 00 00 00 00 	movl   $0x0,-0x60(%rbp)
    12bc:	eb 1f                	jmp    12dd <readMemoryByte+0x5c>
    12be:	8b 45 a0             	mov    -0x60(%rbp),%eax
    12c1:	48 98                	cltq   
    12c3:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
    12ca:	00 
    12cb:	48 8d 05 ee 2e 02 00 	lea    0x22eee(%rip),%rax        # 241c0 <results.0>
    12d2:	c7 04 02 00 00 00 00 	movl   $0x0,(%rdx,%rax,1)
    12d9:	83 45 a0 01          	addl   $0x1,-0x60(%rbp)
    12dd:	81 7d a0 ff 00 00 00 	cmpl   $0xff,-0x60(%rbp)
    12e4:	7e d8                	jle    12be <readMemoryByte+0x3d>
    12e6:	c7 45 9c e7 03 00 00 	movl   $0x3e7,-0x64(%rbp)
    12ed:	e9 fa 02 00 00       	jmp    15ec <readMemoryByte+0x36b>
    12f2:	c7 45 a0 00 00 00 00 	movl   $0x0,-0x60(%rbp)
    12f9:	eb 22                	jmp    131d <readMemoryByte+0x9c>
    12fb:	8b 45 a0             	mov    -0x60(%rbp),%eax
    12fe:	c1 e0 09             	shl    $0x9,%eax
    1301:	48 98                	cltq   
    1303:	48 8d 15 d6 2d 00 00 	lea    0x2dd6(%rip),%rdx        # 40e0 <array2>
    130a:	48 01 d0             	add    %rdx,%rax
    130d:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    1311:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
    1315:	0f ae 38             	clflush (%rax)
    1318:	90                   	nop
    1319:	83 45 a0 01          	addl   $0x1,-0x60(%rbp)
    131d:	81 7d a0 ff 00 00 00 	cmpl   $0xff,-0x60(%rbp)
    1324:	7e d5                	jle    12fb <readMemoryByte+0x7a>
    1326:	8b 0d f4 2c 00 00    	mov    0x2cf4(%rip),%ecx        # 4020 <array1_size>
    132c:	8b 45 9c             	mov    -0x64(%rbp),%eax
    132f:	99                   	cltd   
    1330:	f7 f9                	idiv   %ecx
    1332:	89 d0                	mov    %edx,%eax
    1334:	48 98                	cltq   
    1336:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
    133a:	c7 45 a4 1d 00 00 00 	movl   $0x1d,-0x5c(%rbp)
    1341:	e9 90 00 00 00       	jmp    13d6 <readMemoryByte+0x155>
    1346:	48 8d 05 d3 2c 00 00 	lea    0x2cd3(%rip),%rax        # 4020 <array1_size>
    134d:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
    1351:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
    1355:	0f ae 38             	clflush (%rax)
    1358:	90                   	nop
    1359:	c7 45 98 00 00 00 00 	movl   $0x0,-0x68(%rbp)
    1360:	eb 09                	jmp    136b <readMemoryByte+0xea>
    1362:	8b 45 98             	mov    -0x68(%rbp),%eax
    1365:	83 c0 01             	add    $0x1,%eax
    1368:	89 45 98             	mov    %eax,-0x68(%rbp)
    136b:	8b 45 98             	mov    -0x68(%rbp),%eax
    136e:	83 f8 63             	cmp    $0x63,%eax
    1371:	7e ef                	jle    1362 <readMemoryByte+0xe1>
    1373:	8b 4d a4             	mov    -0x5c(%rbp),%ecx
    1376:	48 63 c1             	movslq %ecx,%rax
    1379:	48 69 c0 ab aa aa 2a 	imul   $0x2aaaaaab,%rax,%rax
    1380:	48 c1 e8 20          	shr    $0x20,%rax
    1384:	89 ce                	mov    %ecx,%esi
    1386:	c1 fe 1f             	sar    $0x1f,%esi
    1389:	89 c2                	mov    %eax,%edx
    138b:	29 f2                	sub    %esi,%edx
    138d:	89 d0                	mov    %edx,%eax
    138f:	01 c0                	add    %eax,%eax
    1391:	01 d0                	add    %edx,%eax
    1393:	01 c0                	add    %eax,%eax
    1395:	29 c1                	sub    %eax,%ecx
    1397:	89 ca                	mov    %ecx,%edx
    1399:	8d 42 ff             	lea    -0x1(%rdx),%eax
    139c:	66 b8 00 00          	mov    $0x0,%ax
    13a0:	48 98                	cltq   
    13a2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
    13a6:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
    13aa:	48 c1 e8 10          	shr    $0x10,%rax
    13ae:	48 09 45 c0          	or     %rax,-0x40(%rbp)
    13b2:	48 8b 45 88          	mov    -0x78(%rbp),%rax
    13b6:	48 33 45 b0          	xor    -0x50(%rbp),%rax
    13ba:	48 23 45 c0          	and    -0x40(%rbp),%rax
    13be:	48 33 45 b0          	xor    -0x50(%rbp),%rax
    13c2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
    13c6:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
    13ca:	48 89 c7             	mov    %rax,%rdi
    13cd:	e8 5f fe ff ff       	call   1231 <victim_function>
    13d2:	83 6d a4 01          	subl   $0x1,-0x5c(%rbp)
    13d6:	83 7d a4 00          	cmpl   $0x0,-0x5c(%rbp)
    13da:	0f 89 66 ff ff ff    	jns    1346 <readMemoryByte+0xc5>
    13e0:	c7 45 a0 00 00 00 00 	movl   $0x0,-0x60(%rbp)
    13e7:	e9 d2 00 00 00       	jmp    14be <readMemoryByte+0x23d>
    13ec:	8b 45 a0             	mov    -0x60(%rbp),%eax
    13ef:	69 c0 a7 00 00 00    	imul   $0xa7,%eax,%eax
    13f5:	83 c0 0d             	add    $0xd,%eax
    13f8:	25 ff 00 00 00       	and    $0xff,%eax
    13fd:	89 45 ac             	mov    %eax,-0x54(%rbp)
    1400:	8b 45 ac             	mov    -0x54(%rbp),%eax
    1403:	c1 e0 09             	shl    $0x9,%eax
    1406:	48 98                	cltq   
    1408:	48 8d 15 d1 2c 00 00 	lea    0x2cd1(%rip),%rdx        # 40e0 <array2>
    140f:	48 01 d0             	add    %rdx,%rax
    1412:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    1416:	48 8d 45 94          	lea    -0x6c(%rbp),%rax
    141a:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
    141e:	0f 01 f9             	rdtscp 
    1421:	89 ce                	mov    %ecx,%esi
    1423:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
    1427:	89 31                	mov    %esi,(%rcx)
    1429:	48 c1 e2 20          	shl    $0x20,%rdx
    142d:	48 09 d0             	or     %rdx,%rax
    1430:	49 89 c4             	mov    %rax,%r12
    1433:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
    1437:	0f b6 00             	movzbl (%rax),%eax
    143a:	0f b6 c0             	movzbl %al,%eax
    143d:	89 45 94             	mov    %eax,-0x6c(%rbp)
    1440:	48 8d 45 94          	lea    -0x6c(%rbp),%rax
    1444:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
    1448:	0f 01 f9             	rdtscp 
    144b:	89 ce                	mov    %ecx,%esi
    144d:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
    1451:	89 31                	mov    %esi,(%rcx)
    1453:	48 c1 e2 20          	shl    $0x20,%rdx
    1457:	48 09 d0             	or     %rdx,%rax
    145a:	4c 29 e0             	sub    %r12,%rax
    145d:	48 89 c3             	mov    %rax,%rbx
    1460:	48 83 fb 32          	cmp    $0x32,%rbx
    1464:	77 54                	ja     14ba <readMemoryByte+0x239>
    1466:	8b 0d b4 2b 00 00    	mov    0x2bb4(%rip),%ecx        # 4020 <array1_size>
    146c:	8b 45 9c             	mov    -0x64(%rbp),%eax
    146f:	99                   	cltd   
    1470:	f7 f9                	idiv   %ecx
    1472:	89 d0                	mov    %edx,%eax
    1474:	48 98                	cltq   
    1476:	48 8d 15 c3 2b 00 00 	lea    0x2bc3(%rip),%rdx        # 4040 <array1>
    147d:	0f b6 04 10          	movzbl (%rax,%rdx,1),%eax
    1481:	0f b6 c0             	movzbl %al,%eax
    1484:	39 45 ac             	cmp    %eax,-0x54(%rbp)
    1487:	74 31                	je     14ba <readMemoryByte+0x239>
    1489:	8b 45 ac             	mov    -0x54(%rbp),%eax
    148c:	48 98                	cltq   
    148e:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
    1495:	00 
    1496:	48 8d 05 23 2d 02 00 	lea    0x22d23(%rip),%rax        # 241c0 <results.0>
    149d:	8b 04 02             	mov    (%rdx,%rax,1),%eax
    14a0:	8d 48 01             	lea    0x1(%rax),%ecx
    14a3:	8b 45 ac             	mov    -0x54(%rbp),%eax
    14a6:	48 98                	cltq   
    14a8:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
    14af:	00 
    14b0:	48 8d 05 09 2d 02 00 	lea    0x22d09(%rip),%rax        # 241c0 <results.0>
    14b7:	89 0c 02             	mov    %ecx,(%rdx,%rax,1)
    14ba:	83 45 a0 01          	addl   $0x1,-0x60(%rbp)
    14be:	81 7d a0 ff 00 00 00 	cmpl   $0xff,-0x60(%rbp)
    14c5:	0f 8e 21 ff ff ff    	jle    13ec <readMemoryByte+0x16b>
    14cb:	c7 45 a8 ff ff ff ff 	movl   $0xffffffff,-0x58(%rbp)
    14d2:	8b 45 a8             	mov    -0x58(%rbp),%eax
    14d5:	89 45 a4             	mov    %eax,-0x5c(%rbp)
    14d8:	c7 45 a0 00 00 00 00 	movl   $0x0,-0x60(%rbp)
    14df:	e9 88 00 00 00       	jmp    156c <readMemoryByte+0x2eb>
    14e4:	83 7d a4 00          	cmpl   $0x0,-0x5c(%rbp)
    14e8:	78 32                	js     151c <readMemoryByte+0x29b>
    14ea:	8b 45 a0             	mov    -0x60(%rbp),%eax
    14ed:	48 98                	cltq   
    14ef:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
    14f6:	00 
    14f7:	48 8d 05 c2 2c 02 00 	lea    0x22cc2(%rip),%rax        # 241c0 <results.0>
    14fe:	8b 14 02             	mov    (%rdx,%rax,1),%edx
    1501:	8b 45 a4             	mov    -0x5c(%rbp),%eax
    1504:	48 98                	cltq   
    1506:	48 8d 0c 85 00 00 00 	lea    0x0(,%rax,4),%rcx
    150d:	00 
    150e:	48 8d 05 ab 2c 02 00 	lea    0x22cab(%rip),%rax        # 241c0 <results.0>
    1515:	8b 04 01             	mov    (%rcx,%rax,1),%eax
    1518:	39 c2                	cmp    %eax,%edx
    151a:	7c 0e                	jl     152a <readMemoryByte+0x2a9>
    151c:	8b 45 a4             	mov    -0x5c(%rbp),%eax
    151f:	89 45 a8             	mov    %eax,-0x58(%rbp)
    1522:	8b 45 a0             	mov    -0x60(%rbp),%eax
    1525:	89 45 a4             	mov    %eax,-0x5c(%rbp)
    1528:	eb 3e                	jmp    1568 <readMemoryByte+0x2e7>
    152a:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
    152e:	78 32                	js     1562 <readMemoryByte+0x2e1>
    1530:	8b 45 a0             	mov    -0x60(%rbp),%eax
    1533:	48 98                	cltq   
    1535:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
    153c:	00 
    153d:	48 8d 05 7c 2c 02 00 	lea    0x22c7c(%rip),%rax        # 241c0 <results.0>
    1544:	8b 14 02             	mov    (%rdx,%rax,1),%edx
    1547:	8b 45 a8             	mov    -0x58(%rbp),%eax
    154a:	48 98                	cltq   
    154c:	48 8d 0c 85 00 00 00 	lea    0x0(,%rax,4),%rcx
    1553:	00 
    1554:	48 8d 05 65 2c 02 00 	lea    0x22c65(%rip),%rax        # 241c0 <results.0>
    155b:	8b 04 01             	mov    (%rcx,%rax,1),%eax
    155e:	39 c2                	cmp    %eax,%edx
    1560:	7c 06                	jl     1568 <readMemoryByte+0x2e7>
    1562:	8b 45 a0             	mov    -0x60(%rbp),%eax
    1565:	89 45 a8             	mov    %eax,-0x58(%rbp)
    1568:	83 45 a0 01          	addl   $0x1,-0x60(%rbp)
    156c:	81 7d a0 ff 00 00 00 	cmpl   $0xff,-0x60(%rbp)
    1573:	0f 8e 6b ff ff ff    	jle    14e4 <readMemoryByte+0x263>
    1579:	8b 45 a8             	mov    -0x58(%rbp),%eax
    157c:	48 98                	cltq   
    157e:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
    1585:	00 
    1586:	48 8d 05 33 2c 02 00 	lea    0x22c33(%rip),%rax        # 241c0 <results.0>
    158d:	8b 04 02             	mov    (%rdx,%rax,1),%eax
    1590:	83 c0 02             	add    $0x2,%eax
    1593:	8d 0c 00             	lea    (%rax,%rax,1),%ecx
    1596:	8b 45 a4             	mov    -0x5c(%rbp),%eax
    1599:	48 98                	cltq   
    159b:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
    15a2:	00 
    15a3:	48 8d 05 16 2c 02 00 	lea    0x22c16(%rip),%rax        # 241c0 <results.0>
    15aa:	8b 04 02             	mov    (%rdx,%rax,1),%eax
    15ad:	39 c1                	cmp    %eax,%ecx
    15af:	7c 45                	jl     15f6 <readMemoryByte+0x375>
    15b1:	8b 45 a4             	mov    -0x5c(%rbp),%eax
    15b4:	48 98                	cltq   
    15b6:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
    15bd:	00 
    15be:	48 8d 05 fb 2b 02 00 	lea    0x22bfb(%rip),%rax        # 241c0 <results.0>
    15c5:	8b 04 02             	mov    (%rdx,%rax,1),%eax
    15c8:	83 f8 02             	cmp    $0x2,%eax
    15cb:	75 1b                	jne    15e8 <readMemoryByte+0x367>
    15cd:	8b 45 a8             	mov    -0x58(%rbp),%eax
    15d0:	48 98                	cltq   
    15d2:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
    15d9:	00 
    15da:	48 8d 05 df 2b 02 00 	lea    0x22bdf(%rip),%rax        # 241c0 <results.0>
    15e1:	8b 04 02             	mov    (%rdx,%rax,1),%eax
    15e4:	85 c0                	test   %eax,%eax
    15e6:	74 0e                	je     15f6 <readMemoryByte+0x375>
    15e8:	83 6d 9c 01          	subl   $0x1,-0x64(%rbp)
    15ec:	83 7d 9c 00          	cmpl   $0x0,-0x64(%rbp)
    15f0:	0f 8f fc fc ff ff    	jg     12f2 <readMemoryByte+0x71>
    15f6:	8b 05 c4 2b 02 00    	mov    0x22bc4(%rip),%eax        # 241c0 <results.0>
    15fc:	89 c2                	mov    %eax,%edx
    15fe:	8b 45 94             	mov    -0x6c(%rbp),%eax
    1601:	31 d0                	xor    %edx,%eax
    1603:	89 05 b7 2b 02 00    	mov    %eax,0x22bb7(%rip)        # 241c0 <results.0>
    1609:	8b 45 a4             	mov    -0x5c(%rbp),%eax
    160c:	89 c2                	mov    %eax,%edx
    160e:	48 8b 45 80          	mov    -0x80(%rbp),%rax
    1612:	88 10                	mov    %dl,(%rax)
    1614:	8b 45 a4             	mov    -0x5c(%rbp),%eax
    1617:	48 98                	cltq   
    1619:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
    1620:	00 
    1621:	48 8d 05 98 2b 02 00 	lea    0x22b98(%rip),%rax        # 241c0 <results.0>
    1628:	8b 14 02             	mov    (%rdx,%rax,1),%edx
    162b:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
    1632:	89 10                	mov    %edx,(%rax)
    1634:	48 8b 45 80          	mov    -0x80(%rbp),%rax
    1638:	48 83 c0 01          	add    $0x1,%rax
    163c:	8b 55 a8             	mov    -0x58(%rbp),%edx
    163f:	88 10                	mov    %dl,(%rax)
    1641:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
    1648:	48 8d 50 04          	lea    0x4(%rax),%rdx
    164c:	8b 45 a8             	mov    -0x58(%rbp),%eax
    164f:	48 98                	cltq   
    1651:	48 8d 0c 85 00 00 00 	lea    0x0(,%rax,4),%rcx
    1658:	00 
    1659:	48 8d 05 60 2b 02 00 	lea    0x22b60(%rip),%rax        # 241c0 <results.0>
    1660:	8b 04 01             	mov    (%rcx,%rax,1),%eax
    1663:	89 02                	mov    %eax,(%rdx)
    1665:	90                   	nop
    1666:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    166a:	64 48 2b 04 25 28 00 	sub    %fs:0x28,%rax
    1671:	00 00 
    1673:	74 05                	je     167a <readMemoryByte+0x3f9>
    1675:	e8 66 fa ff ff       	call   10e0 <__stack_chk_fail@plt>
    167a:	48 83 ec 80          	sub    $0xffffffffffffff80,%rsp
    167e:	5b                   	pop    %rbx
    167f:	41 5c                	pop    %r12
    1681:	5d                   	pop    %rbp
    1682:	c3                   	ret    

0000000000001683 <main>:
    1683:	f3 0f 1e fa          	endbr64 
    1687:	55                   	push   %rbp
    1688:	48 89 e5             	mov    %rsp,%rbp
    168b:	48 83 ec 50          	sub    $0x50,%rsp
    168f:	89 7d bc             	mov    %edi,-0x44(%rbp)
    1692:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
    1696:	64 48 8b 04 25 28 00 	mov    %fs:0x28,%rax
    169d:	00 00 
    169f:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    16a3:	31 c0                	xor    %eax,%eax
    16a5:	e8 56 fa ff ff       	call   1100 <getchar@plt>
    16aa:	88 45 cf             	mov    %al,-0x31(%rbp)
    16ad:	80 7d cf 72          	cmpb   $0x72,-0x31(%rbp)
    16b1:	0f 85 42 02 00 00    	jne    18f9 <main+0x276>
    16b7:	48 8b 15 22 2a 02 00 	mov    0x22a22(%rip),%rdx        # 240e0 <secret>
    16be:	48 8b 05 1b 2a 02 00 	mov    0x22a1b(%rip),%rax        # 240e0 <secret>
    16c5:	48 89 c6             	mov    %rax,%rsi
    16c8:	48 8d 05 69 09 00 00 	lea    0x969(%rip),%rax        # 2038 <_IO_stdin_used+0x38>
    16cf:	48 89 c7             	mov    %rax,%rdi
    16d2:	b8 00 00 00 00       	mov    $0x0,%eax
    16d7:	e8 14 fa ff ff       	call   10f0 <printf@plt>
    16dc:	48 8b 05 fd 29 02 00 	mov    0x229fd(%rip),%rax        # 240e0 <secret>
    16e3:	48 8d 15 56 29 00 00 	lea    0x2956(%rip),%rdx        # 4040 <array1>
    16ea:	48 29 d0             	sub    %rdx,%rax
    16ed:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
    16f1:	48 8b 05 e8 29 02 00 	mov    0x229e8(%rip),%rax        # 240e0 <secret>
    16f8:	48 89 c7             	mov    %rax,%rdi
    16fb:	e8 d0 f9 ff ff       	call   10d0 <strlen@plt>
    1700:	89 45 d0             	mov    %eax,-0x30(%rbp)
    1703:	48 c7 45 e0 00 00 00 	movq   $0x0,-0x20(%rbp)
    170a:	00 
    170b:	eb 16                	jmp    1723 <main+0xa0>
    170d:	48 8d 15 cc 29 00 00 	lea    0x29cc(%rip),%rdx        # 40e0 <array2>
    1714:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
    1718:	48 01 d0             	add    %rdx,%rax
    171b:	c6 00 01             	movb   $0x1,(%rax)
    171e:	48 83 45 e0 01       	addq   $0x1,-0x20(%rbp)
    1723:	48 81 7d e0 ff ff 01 	cmpq   $0x1ffff,-0x20(%rbp)
    172a:	00 
    172b:	76 e0                	jbe    170d <main+0x8a>
    172d:	83 7d bc 03          	cmpl   $0x3,-0x44(%rbp)
    1731:	0f 85 81 00 00 00    	jne    17b8 <main+0x135>
    1737:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
    173b:	48 83 c0 08          	add    $0x8,%rax
    173f:	48 8b 00             	mov    (%rax),%rax
    1742:	48 8d 55 d8          	lea    -0x28(%rbp),%rdx
    1746:	48 8d 0d 0f 09 00 00 	lea    0x90f(%rip),%rcx        # 205c <_IO_stdin_used+0x5c>
    174d:	48 89 ce             	mov    %rcx,%rsi
    1750:	48 89 c7             	mov    %rax,%rdi
    1753:	b8 00 00 00 00       	mov    $0x0,%eax
    1758:	e8 b3 f9 ff ff       	call   1110 <__isoc99_sscanf@plt>
    175d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
    1761:	48 8d 15 d8 28 00 00 	lea    0x28d8(%rip),%rdx        # 4040 <array1>
    1768:	48 29 d0             	sub    %rdx,%rax
    176b:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
    176f:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
    1773:	48 83 c0 10          	add    $0x10,%rax
    1777:	48 8b 00             	mov    (%rax),%rax
    177a:	48 8d 55 d0          	lea    -0x30(%rbp),%rdx
    177e:	48 8d 0d da 08 00 00 	lea    0x8da(%rip),%rcx        # 205f <_IO_stdin_used+0x5f>
    1785:	48 89 ce             	mov    %rcx,%rsi
    1788:	48 89 c7             	mov    %rax,%rdi
    178b:	b8 00 00 00 00       	mov    $0x0,%eax
    1790:	e8 7b f9 ff ff       	call   1110 <__isoc99_sscanf@plt>
    1795:	8b 45 d0             	mov    -0x30(%rbp),%eax
    1798:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
    179c:	48 89 d1             	mov    %rdx,%rcx
    179f:	89 c2                	mov    %eax,%edx
    17a1:	48 89 ce             	mov    %rcx,%rsi
    17a4:	48 8d 05 bd 08 00 00 	lea    0x8bd(%rip),%rax        # 2068 <_IO_stdin_used+0x68>
    17ab:	48 89 c7             	mov    %rax,%rdi
    17ae:	b8 00 00 00 00       	mov    $0x0,%eax
    17b3:	e8 38 f9 ff ff       	call   10f0 <printf@plt>
    17b8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%rbp)
    17bf:	e9 1c 01 00 00       	jmp    18e0 <main+0x25d>
    17c4:	48 8b 15 15 29 02 00 	mov    0x22915(%rip),%rdx        # 240e0 <secret>
    17cb:	8b 45 d4             	mov    -0x2c(%rbp),%eax
    17ce:	48 98                	cltq   
    17d0:	48 01 d0             	add    %rdx,%rax
    17d3:	0f b6 00             	movzbl (%rax),%eax
    17d6:	0f be c0             	movsbl %al,%eax
    17d9:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
    17dd:	48 89 d1             	mov    %rdx,%rcx
    17e0:	89 c2                	mov    %eax,%edx
    17e2:	48 89 ce             	mov    %rcx,%rsi
    17e5:	48 8d 05 a4 08 00 00 	lea    0x8a4(%rip),%rax        # 2090 <_IO_stdin_used+0x90>
    17ec:	48 89 c7             	mov    %rax,%rdi
    17ef:	b8 00 00 00 00       	mov    $0x0,%eax
    17f4:	e8 f7 f8 ff ff       	call   10f0 <printf@plt>
    17f9:	83 45 d4 01          	addl   $0x1,-0x2c(%rbp)
    17fd:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
    1801:	48 8d 50 01          	lea    0x1(%rax),%rdx
    1805:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    1809:	48 8d 55 ec          	lea    -0x14(%rbp),%rdx
    180d:	48 8d 4d f6          	lea    -0xa(%rbp),%rcx
    1811:	48 89 ce             	mov    %rcx,%rsi
    1814:	48 89 c7             	mov    %rax,%rdi
    1817:	e8 65 fa ff ff       	call   1281 <readMemoryByte>
    181c:	8b 45 ec             	mov    -0x14(%rbp),%eax
    181f:	8b 55 f0             	mov    -0x10(%rbp),%edx
    1822:	01 d2                	add    %edx,%edx
    1824:	39 d0                	cmp    %edx,%eax
    1826:	7c 09                	jl     1831 <main+0x1ae>
    1828:	48 8d 05 8a 08 00 00 	lea    0x88a(%rip),%rax        # 20b9 <_IO_stdin_used+0xb9>
    182f:	eb 07                	jmp    1838 <main+0x1b5>
    1831:	48 8d 05 89 08 00 00 	lea    0x889(%rip),%rax        # 20c1 <_IO_stdin_used+0xc1>
    1838:	48 89 c6             	mov    %rax,%rsi
    183b:	48 8d 05 87 08 00 00 	lea    0x887(%rip),%rax        # 20c9 <_IO_stdin_used+0xc9>
    1842:	48 89 c7             	mov    %rax,%rdi
    1845:	b8 00 00 00 00       	mov    $0x0,%eax
    184a:	e8 a1 f8 ff ff       	call   10f0 <printf@plt>
    184f:	8b 55 ec             	mov    -0x14(%rbp),%edx
    1852:	0f b6 45 f6          	movzbl -0xa(%rbp),%eax
    1856:	3c 1f                	cmp    $0x1f,%al
    1858:	76 11                	jbe    186b <main+0x1e8>
    185a:	0f b6 45 f6          	movzbl -0xa(%rbp),%eax
    185e:	3c 7e                	cmp    $0x7e,%al
    1860:	77 09                	ja     186b <main+0x1e8>
    1862:	0f b6 45 f6          	movzbl -0xa(%rbp),%eax
    1866:	0f b6 c0             	movzbl %al,%eax
    1869:	eb 05                	jmp    1870 <main+0x1ed>
    186b:	b8 3f 00 00 00       	mov    $0x3f,%eax
    1870:	0f b6 4d f6          	movzbl -0xa(%rbp),%ecx
    1874:	0f b6 f1             	movzbl %cl,%esi
    1877:	89 d1                	mov    %edx,%ecx
    1879:	89 c2                	mov    %eax,%edx
    187b:	48 8d 05 4c 08 00 00 	lea    0x84c(%rip),%rax        # 20ce <_IO_stdin_used+0xce>
    1882:	48 89 c7             	mov    %rax,%rdi
    1885:	b8 00 00 00 00       	mov    $0x0,%eax
    188a:	e8 61 f8 ff ff       	call   10f0 <printf@plt>
    188f:	8b 45 f0             	mov    -0x10(%rbp),%eax
    1892:	85 c0                	test   %eax,%eax
    1894:	7e 40                	jle    18d6 <main+0x253>
    1896:	8b 55 f0             	mov    -0x10(%rbp),%edx
    1899:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
    189d:	3c 1f                	cmp    $0x1f,%al
    189f:	76 11                	jbe    18b2 <main+0x22f>
    18a1:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
    18a5:	3c 7e                	cmp    $0x7e,%al
    18a7:	77 09                	ja     18b2 <main+0x22f>
    18a9:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
    18ad:	0f b6 c0             	movzbl %al,%eax
    18b0:	eb 05                	jmp    18b7 <main+0x234>
    18b2:	b8 3f 00 00 00       	mov    $0x3f,%eax
    18b7:	0f b6 4d f7          	movzbl -0x9(%rbp),%ecx
    18bb:	0f b6 f1             	movzbl %cl,%esi
    18be:	89 d1                	mov    %edx,%ecx
    18c0:	89 c2                	mov    %eax,%edx
    18c2:	48 8d 05 1f 08 00 00 	lea    0x81f(%rip),%rax        # 20e8 <_IO_stdin_used+0xe8>
    18c9:	48 89 c7             	mov    %rax,%rdi
    18cc:	b8 00 00 00 00       	mov    $0x0,%eax
    18d1:	e8 1a f8 ff ff       	call   10f0 <printf@plt>
    18d6:	bf 0a 00 00 00       	mov    $0xa,%edi
    18db:	e8 d0 f7 ff ff       	call   10b0 <putchar@plt>
    18e0:	8b 45 d0             	mov    -0x30(%rbp),%eax
    18e3:	83 e8 01             	sub    $0x1,%eax
    18e6:	89 45 d0             	mov    %eax,-0x30(%rbp)
    18e9:	8b 45 d0             	mov    -0x30(%rbp),%eax
    18ec:	85 c0                	test   %eax,%eax
    18ee:	0f 89 d0 fe ff ff    	jns    17c4 <main+0x141>
    18f4:	e9 ac fd ff ff       	jmp    16a5 <main+0x22>
    18f9:	80 7d cf 0a          	cmpb   $0xa,-0x31(%rbp)
    18fd:	74 39                	je     1938 <main+0x2b5>
    18ff:	80 7d cf 69          	cmpb   $0x69,-0x31(%rbp)
    1903:	75 39                	jne    193e <main+0x2bb>
    1905:	b8 00 00 00 00       	mov    $0x0,%eax
    190a:	e8 b1 f7 ff ff       	call   10c0 <getpid@plt>
    190f:	89 c2                	mov    %eax,%edx
    1911:	48 8d 05 f1 f8 ff ff 	lea    -0x70f(%rip),%rax        # 1209 <check>
    1918:	48 83 c0 21          	add    $0x21,%rax
    191c:	48 89 c6             	mov    %rax,%rsi
    191f:	48 8d 05 e6 07 00 00 	lea    0x7e6(%rip),%rax        # 210c <_IO_stdin_used+0x10c>
    1926:	48 89 c7             	mov    %rax,%rdi
    1929:	b8 00 00 00 00       	mov    $0x0,%eax
    192e:	e8 bd f7 ff ff       	call   10f0 <printf@plt>
    1933:	e9 6d fd ff ff       	jmp    16a5 <main+0x22>
    1938:	90                   	nop
    1939:	e9 67 fd ff ff       	jmp    16a5 <main+0x22>
    193e:	90                   	nop
    193f:	b8 00 00 00 00       	mov    $0x0,%eax
    1944:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
    1948:	64 48 2b 14 25 28 00 	sub    %fs:0x28,%rdx
    194f:	00 00 
    1951:	74 05                	je     1958 <main+0x2d5>
    1953:	e8 88 f7 ff ff       	call   10e0 <__stack_chk_fail@plt>
    1958:	c9                   	leave  
    1959:	c3                   	ret    

Disassembly of section .fini:

000000000000195c <_fini>:
    195c:	f3 0f 1e fa          	endbr64 
    1960:	48 83 ec 08          	sub    $0x8,%rsp
    1964:	48 83 c4 08          	add    $0x8,%rsp
    1968:	c3                   	ret    
