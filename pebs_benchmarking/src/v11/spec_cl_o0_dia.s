
spec_cl_o0.out      elf64-x86-64


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

0000000000001020 <getpid@plt-0x10>:
    1020:	ff 35 e2 2f 00 00    	push   0x2fe2(%rip)        # 4008 <_GLOBAL_OFFSET_TABLE_+0x8>
    1026:	ff 25 e4 2f 00 00    	jmp    *0x2fe4(%rip)        # 4010 <_GLOBAL_OFFSET_TABLE_+0x10>
    102c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000001030 <getpid@plt>:
    1030:	ff 25 e2 2f 00 00    	jmp    *0x2fe2(%rip)        # 4018 <getpid@GLIBC_2.2.5>
    1036:	68 00 00 00 00       	push   $0x0
    103b:	e9 e0 ff ff ff       	jmp    1020 <_init+0x20>

0000000000001040 <strlen@plt>:
    1040:	ff 25 da 2f 00 00    	jmp    *0x2fda(%rip)        # 4020 <strlen@GLIBC_2.2.5>
    1046:	68 01 00 00 00       	push   $0x1
    104b:	e9 d0 ff ff ff       	jmp    1020 <_init+0x20>

0000000000001050 <printf@plt>:
    1050:	ff 25 d2 2f 00 00    	jmp    *0x2fd2(%rip)        # 4028 <printf@GLIBC_2.2.5>
    1056:	68 02 00 00 00       	push   $0x2
    105b:	e9 c0 ff ff ff       	jmp    1020 <_init+0x20>

0000000000001060 <memcmp@plt>:
    1060:	ff 25 ca 2f 00 00    	jmp    *0x2fca(%rip)        # 4030 <memcmp@GLIBC_2.2.5>
    1066:	68 03 00 00 00       	push   $0x3
    106b:	e9 b0 ff ff ff       	jmp    1020 <_init+0x20>

0000000000001070 <getchar@plt>:
    1070:	ff 25 c2 2f 00 00    	jmp    *0x2fc2(%rip)        # 4038 <getchar@GLIBC_2.2.5>
    1076:	68 04 00 00 00       	push   $0x4
    107b:	e9 a0 ff ff ff       	jmp    1020 <_init+0x20>

0000000000001080 <__isoc99_sscanf@plt>:
    1080:	ff 25 ba 2f 00 00    	jmp    *0x2fba(%rip)        # 4040 <__isoc99_sscanf@GLIBC_2.7>
    1086:	68 05 00 00 00       	push   $0x5
    108b:	e9 90 ff ff ff       	jmp    1020 <_init+0x20>

Disassembly of section .plt.got:

0000000000001090 <__cxa_finalize@plt>:
    1090:	ff 25 62 2f 00 00    	jmp    *0x2f62(%rip)        # 3ff8 <__cxa_finalize@GLIBC_2.2.5>
    1096:	66 90                	xchg   %ax,%ax

Disassembly of section .text:

00000000000010a0 <_start>:
    10a0:	f3 0f 1e fa          	endbr64 
    10a4:	31 ed                	xor    %ebp,%ebp
    10a6:	49 89 d1             	mov    %rdx,%r9
    10a9:	5e                   	pop    %rsi
    10aa:	48 89 e2             	mov    %rsp,%rdx
    10ad:	48 83 e4 f0          	and    $0xfffffffffffffff0,%rsp
    10b1:	50                   	push   %rax
    10b2:	54                   	push   %rsp
    10b3:	45 31 c0             	xor    %r8d,%r8d
    10b6:	31 c9                	xor    %ecx,%ecx
    10b8:	48 8d 3d d1 04 00 00 	lea    0x4d1(%rip),%rdi        # 1590 <main>
    10bf:	ff 15 13 2f 00 00    	call   *0x2f13(%rip)        # 3fd8 <__libc_start_main@GLIBC_2.34>
    10c5:	f4                   	hlt    
    10c6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    10cd:	00 00 00 

00000000000010d0 <deregister_tm_clones>:
    10d0:	48 8d 3d 41 30 00 00 	lea    0x3041(%rip),%rdi        # 4118 <__TMC_END__>
    10d7:	48 8d 05 3a 30 00 00 	lea    0x303a(%rip),%rax        # 4118 <__TMC_END__>
    10de:	48 39 f8             	cmp    %rdi,%rax
    10e1:	74 15                	je     10f8 <deregister_tm_clones+0x28>
    10e3:	48 8b 05 f6 2e 00 00 	mov    0x2ef6(%rip),%rax        # 3fe0 <_ITM_deregisterTMCloneTable@Base>
    10ea:	48 85 c0             	test   %rax,%rax
    10ed:	74 09                	je     10f8 <deregister_tm_clones+0x28>
    10ef:	ff e0                	jmp    *%rax
    10f1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    10f8:	c3                   	ret    
    10f9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000001100 <register_tm_clones>:
    1100:	48 8d 3d 11 30 00 00 	lea    0x3011(%rip),%rdi        # 4118 <__TMC_END__>
    1107:	48 8d 35 0a 30 00 00 	lea    0x300a(%rip),%rsi        # 4118 <__TMC_END__>
    110e:	48 29 fe             	sub    %rdi,%rsi
    1111:	48 89 f0             	mov    %rsi,%rax
    1114:	48 c1 ee 3f          	shr    $0x3f,%rsi
    1118:	48 c1 f8 03          	sar    $0x3,%rax
    111c:	48 01 c6             	add    %rax,%rsi
    111f:	48 d1 fe             	sar    %rsi
    1122:	74 14                	je     1138 <register_tm_clones+0x38>
    1124:	48 8b 05 c5 2e 00 00 	mov    0x2ec5(%rip),%rax        # 3ff0 <_ITM_registerTMCloneTable@Base>
    112b:	48 85 c0             	test   %rax,%rax
    112e:	74 08                	je     1138 <register_tm_clones+0x38>
    1130:	ff e0                	jmp    *%rax
    1132:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    1138:	c3                   	ret    
    1139:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000001140 <__do_global_dtors_aux>:
    1140:	f3 0f 1e fa          	endbr64 
    1144:	80 3d d5 2f 00 00 00 	cmpb   $0x0,0x2fd5(%rip)        # 4120 <completed.0>
    114b:	75 2b                	jne    1178 <__do_global_dtors_aux+0x38>
    114d:	55                   	push   %rbp
    114e:	48 83 3d a2 2e 00 00 	cmpq   $0x0,0x2ea2(%rip)        # 3ff8 <__cxa_finalize@GLIBC_2.2.5>
    1155:	00 
    1156:	48 89 e5             	mov    %rsp,%rbp
    1159:	74 0c                	je     1167 <__do_global_dtors_aux+0x27>
    115b:	48 8b 3d f6 2e 00 00 	mov    0x2ef6(%rip),%rdi        # 4058 <__dso_handle>
    1162:	e8 29 ff ff ff       	call   1090 <__cxa_finalize@plt>
    1167:	e8 64 ff ff ff       	call   10d0 <deregister_tm_clones>
    116c:	c6 05 ad 2f 00 00 01 	movb   $0x1,0x2fad(%rip)        # 4120 <completed.0>
    1173:	5d                   	pop    %rbp
    1174:	c3                   	ret    
    1175:	0f 1f 00             	nopl   (%rax)
    1178:	c3                   	ret    
    1179:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000001180 <frame_dummy>:
    1180:	f3 0f 1e fa          	endbr64 
    1184:	e9 77 ff ff ff       	jmp    1100 <register_tm_clones>
    1189:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000001190 <check>:
    1190:	55                   	push   %rbp
    1191:	48 89 e5             	mov    %rsp,%rbp
    1194:	48 89 7d f0          	mov    %rdi,-0x10(%rbp)
    1198:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    119c:	8b 0d be 2e 00 00    	mov    0x2ebe(%rip),%ecx        # 4060 <array1_size>
    11a2:	48 63 c9             	movslq %ecx,%rcx
    11a5:	48 39 c8             	cmp    %rcx,%rax
    11a8:	73 09                	jae    11b3 <check+0x23>
    11aa:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)
    11b1:	eb 07                	jmp    11ba <check+0x2a>
    11b3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    11ba:	8b 45 fc             	mov    -0x4(%rbp),%eax
    11bd:	5d                   	pop    %rbp
    11be:	c3                   	ret    
    11bf:	90                   	nop

00000000000011c0 <victim_function>:
    11c0:	55                   	push   %rbp
    11c1:	48 89 e5             	mov    %rsp,%rbp
    11c4:	48 83 ec 10          	sub    $0x10,%rsp
    11c8:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
    11cc:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    11d0:	8b 0d 8a 2e 00 00    	mov    0x2e8a(%rip),%ecx        # 4060 <array1_size>
    11d6:	48 63 c9             	movslq %ecx,%rcx
    11d9:	48 39 c8             	cmp    %rcx,%rax
    11dc:	73 35                	jae    1213 <victim_function+0x53>
    11de:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
    11e2:	48 8d 05 87 2e 00 00 	lea    0x2e87(%rip),%rax        # 4070 <array1>
    11e9:	0f b6 04 08          	movzbl (%rax,%rcx,1),%eax
    11ed:	c1 e0 09             	shl    $0x9,%eax
    11f0:	48 98                	cltq   
    11f2:	48 8d 35 47 2f 00 00 	lea    0x2f47(%rip),%rsi        # 4140 <array2>
    11f9:	48 01 c6             	add    %rax,%rsi
    11fc:	48 8d 3d 2d 2f 00 00 	lea    0x2f2d(%rip),%rdi        # 4130 <temp>
    1203:	ba 01 00 00 00       	mov    $0x1,%edx
    1208:	e8 53 fe ff ff       	call   1060 <memcmp@plt>
    120d:	88 05 1d 2f 00 00    	mov    %al,0x2f1d(%rip)        # 4130 <temp>
    1213:	48 83 c4 10          	add    $0x10,%rsp
    1217:	5d                   	pop    %rbp
    1218:	c3                   	ret    
    1219:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000001220 <readMemoryByte>:
    1220:	55                   	push   %rbp
    1221:	48 89 e5             	mov    %rsp,%rbp
    1224:	48 81 ec 90 00 00 00 	sub    $0x90,%rsp
    122b:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
    122f:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
    1233:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    1237:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%rbp)
    123e:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%rbp)
    1245:	81 7d d0 00 01 00 00 	cmpl   $0x100,-0x30(%rbp)
    124c:	7d 1d                	jge    126b <readMemoryByte+0x4b>
    124e:	48 63 4d d0          	movslq -0x30(%rbp),%rcx
    1252:	48 8d 05 e7 2e 02 00 	lea    0x22ee7(%rip),%rax        # 24140 <readMemoryByte.results>
    1259:	c7 04 88 00 00 00 00 	movl   $0x0,(%rax,%rcx,4)
    1260:	8b 45 d0             	mov    -0x30(%rbp),%eax
    1263:	83 c0 01             	add    $0x1,%eax
    1266:	89 45 d0             	mov    %eax,-0x30(%rbp)
    1269:	eb da                	jmp    1245 <readMemoryByte+0x25>
    126b:	c7 45 d4 e7 03 00 00 	movl   $0x3e7,-0x2c(%rbp)
    1272:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
    1276:	0f 8e b7 02 00 00    	jle    1533 <readMemoryByte+0x313>
    127c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%rbp)
    1283:	81 7d d0 00 01 00 00 	cmpl   $0x100,-0x30(%rbp)
    128a:	7d 21                	jge    12ad <readMemoryByte+0x8d>
    128c:	8b 45 d0             	mov    -0x30(%rbp),%eax
    128f:	c1 e0 09             	shl    $0x9,%eax
    1292:	48 63 c8             	movslq %eax,%rcx
    1295:	48 8d 05 a4 2e 00 00 	lea    0x2ea4(%rip),%rax        # 4140 <array2>
    129c:	48 01 c8             	add    %rcx,%rax
    129f:	0f ae 38             	clflush (%rax)
    12a2:	8b 45 d0             	mov    -0x30(%rbp),%eax
    12a5:	83 c0 01             	add    $0x1,%eax
    12a8:	89 45 d0             	mov    %eax,-0x30(%rbp)
    12ab:	eb d6                	jmp    1283 <readMemoryByte+0x63>
    12ad:	8b 45 d4             	mov    -0x2c(%rbp),%eax
    12b0:	8b 0d aa 2d 00 00    	mov    0x2daa(%rip),%ecx        # 4060 <array1_size>
    12b6:	99                   	cltd   
    12b7:	f7 f9                	idiv   %ecx
    12b9:	48 63 c2             	movslq %edx,%rax
    12bc:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    12c0:	c7 45 cc 1d 00 00 00 	movl   $0x1d,-0x34(%rbp)
    12c7:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
    12cb:	0f 8c 82 00 00 00    	jl     1353 <readMemoryByte+0x133>
    12d1:	0f ae 3d 88 2d 00 00 	clflush 0x2d88(%rip)        # 4060 <array1_size>
    12d8:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%rbp)
    12df:	8b 45 94             	mov    -0x6c(%rbp),%eax
    12e2:	83 f8 64             	cmp    $0x64,%eax
    12e5:	7d 0d                	jge    12f4 <readMemoryByte+0xd4>
    12e7:	eb 00                	jmp    12e9 <readMemoryByte+0xc9>
    12e9:	8b 45 94             	mov    -0x6c(%rbp),%eax
    12ec:	83 c0 01             	add    $0x1,%eax
    12ef:	89 45 94             	mov    %eax,-0x6c(%rbp)
    12f2:	eb eb                	jmp    12df <readMemoryByte+0xbf>
    12f4:	8b 45 cc             	mov    -0x34(%rbp),%eax
    12f7:	b9 06 00 00 00       	mov    $0x6,%ecx
    12fc:	99                   	cltd   
    12fd:	f7 f9                	idiv   %ecx
    12ff:	89 d0                	mov    %edx,%eax
    1301:	83 e8 01             	sub    $0x1,%eax
    1304:	25 00 00 ff ff       	and    $0xffff0000,%eax
    1309:	48 98                	cltq   
    130b:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
    130f:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
    1313:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
    1317:	48 c1 e9 10          	shr    $0x10,%rcx
    131b:	48 09 c8             	or     %rcx,%rax
    131e:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
    1322:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
    1326:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
    132a:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
    132e:	48 33 55 b8          	xor    -0x48(%rbp),%rdx
    1332:	48 21 d1             	and    %rdx,%rcx
    1335:	48 31 c8             	xor    %rcx,%rax
    1338:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
    133c:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
    1340:	e8 7b fe ff ff       	call   11c0 <victim_function>
    1345:	8b 45 cc             	mov    -0x34(%rbp),%eax
    1348:	83 c0 ff             	add    $0xffffffff,%eax
    134b:	89 45 cc             	mov    %eax,-0x34(%rbp)
    134e:	e9 74 ff ff ff       	jmp    12c7 <readMemoryByte+0xa7>
    1353:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%rbp)
    135a:	81 7d d0 00 01 00 00 	cmpl   $0x100,-0x30(%rbp)
    1361:	0f 8d ea 00 00 00    	jge    1451 <readMemoryByte+0x231>
    1367:	69 45 d0 a7 00 00 00 	imul   $0xa7,-0x30(%rbp),%eax
    136e:	83 c0 0d             	add    $0xd,%eax
    1371:	25 ff 00 00 00       	and    $0xff,%eax
    1376:	89 45 c4             	mov    %eax,-0x3c(%rbp)
    1379:	8b 45 c4             	mov    -0x3c(%rbp),%eax
    137c:	c1 e0 09             	shl    $0x9,%eax
    137f:	48 63 c8             	movslq %eax,%rcx
    1382:	48 8d 05 b7 2d 00 00 	lea    0x2db7(%rip),%rax        # 4140 <array2>
    1389:	48 01 c8             	add    %rcx,%rax
    138c:	48 89 45 98          	mov    %rax,-0x68(%rbp)
    1390:	48 8d 45 c0          	lea    -0x40(%rbp),%rax
    1394:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    1398:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    139c:	48 89 45 80          	mov    %rax,-0x80(%rbp)
    13a0:	0f 01 f9             	rdtscp 
    13a3:	48 89 d6             	mov    %rdx,%rsi
    13a6:	89 ca                	mov    %ecx,%edx
    13a8:	48 8b 4d 80          	mov    -0x80(%rbp),%rcx
    13ac:	48 c1 e6 20          	shl    $0x20,%rsi
    13b0:	48 09 f0             	or     %rsi,%rax
    13b3:	89 11                	mov    %edx,(%rcx)
    13b5:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
    13b9:	48 8b 45 98          	mov    -0x68(%rbp),%rax
    13bd:	8a 00                	mov    (%rax),%al
    13bf:	0f b6 c0             	movzbl %al,%eax
    13c2:	89 45 c0             	mov    %eax,-0x40(%rbp)
    13c5:	48 8d 45 c0          	lea    -0x40(%rbp),%rax
    13c9:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    13cd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    13d1:	48 89 45 88          	mov    %rax,-0x78(%rbp)
    13d5:	0f 01 f9             	rdtscp 
    13d8:	48 89 d6             	mov    %rdx,%rsi
    13db:	89 ca                	mov    %ecx,%edx
    13dd:	48 8b 4d 88          	mov    -0x78(%rbp),%rcx
    13e1:	48 c1 e6 20          	shl    $0x20,%rsi
    13e5:	48 09 f0             	or     %rsi,%rax
    13e8:	89 11                	mov    %edx,(%rcx)
    13ea:	48 2b 45 a8          	sub    -0x58(%rbp),%rax
    13ee:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
    13f2:	48 83 7d a0 64       	cmpq   $0x64,-0x60(%rbp)
    13f7:	77 48                	ja     1441 <readMemoryByte+0x221>
    13f9:	8b 45 c4             	mov    -0x3c(%rbp),%eax
    13fc:	89 85 7c ff ff ff    	mov    %eax,-0x84(%rbp)
    1402:	8b 45 d4             	mov    -0x2c(%rbp),%eax
    1405:	8b 0d 55 2c 00 00    	mov    0x2c55(%rip),%ecx        # 4060 <array1_size>
    140b:	99                   	cltd   
    140c:	f7 f9                	idiv   %ecx
    140e:	8b 85 7c ff ff ff    	mov    -0x84(%rbp),%eax
    1414:	48 63 d2             	movslq %edx,%rdx
    1417:	48 8d 0d 52 2c 00 00 	lea    0x2c52(%rip),%rcx        # 4070 <array1>
    141e:	0f b6 0c 11          	movzbl (%rcx,%rdx,1),%ecx
    1422:	39 c8                	cmp    %ecx,%eax
    1424:	74 1b                	je     1441 <readMemoryByte+0x221>
    1426:	48 63 4d c4          	movslq -0x3c(%rbp),%rcx
    142a:	48 8d 05 0f 2d 02 00 	lea    0x22d0f(%rip),%rax        # 24140 <readMemoryByte.results>
    1431:	8b 14 88             	mov    (%rax,%rcx,4),%edx
    1434:	83 c2 01             	add    $0x1,%edx
    1437:	48 8d 05 02 2d 02 00 	lea    0x22d02(%rip),%rax        # 24140 <readMemoryByte.results>
    143e:	89 14 88             	mov    %edx,(%rax,%rcx,4)
    1441:	eb 00                	jmp    1443 <readMemoryByte+0x223>
    1443:	8b 45 d0             	mov    -0x30(%rbp),%eax
    1446:	83 c0 01             	add    $0x1,%eax
    1449:	89 45 d0             	mov    %eax,-0x30(%rbp)
    144c:	e9 09 ff ff ff       	jmp    135a <readMemoryByte+0x13a>
    1451:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%rbp)
    1458:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%rbp)
    145f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%rbp)
    1466:	81 7d d0 00 01 00 00 	cmpl   $0x100,-0x30(%rbp)
    146d:	7d 6b                	jge    14da <readMemoryByte+0x2ba>
    146f:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
    1473:	7c 1e                	jl     1493 <readMemoryByte+0x273>
    1475:	48 63 4d d0          	movslq -0x30(%rbp),%rcx
    1479:	48 8d 05 c0 2c 02 00 	lea    0x22cc0(%rip),%rax        # 24140 <readMemoryByte.results>
    1480:	8b 04 88             	mov    (%rax,%rcx,4),%eax
    1483:	48 63 55 cc          	movslq -0x34(%rbp),%rdx
    1487:	48 8d 0d b2 2c 02 00 	lea    0x22cb2(%rip),%rcx        # 24140 <readMemoryByte.results>
    148e:	3b 04 91             	cmp    (%rcx,%rdx,4),%eax
    1491:	7c 0e                	jl     14a1 <readMemoryByte+0x281>
    1493:	8b 45 cc             	mov    -0x34(%rbp),%eax
    1496:	89 45 c8             	mov    %eax,-0x38(%rbp)
    1499:	8b 45 d0             	mov    -0x30(%rbp),%eax
    149c:	89 45 cc             	mov    %eax,-0x34(%rbp)
    149f:	eb 2c                	jmp    14cd <readMemoryByte+0x2ad>
    14a1:	83 7d c8 00          	cmpl   $0x0,-0x38(%rbp)
    14a5:	7c 1e                	jl     14c5 <readMemoryByte+0x2a5>
    14a7:	48 63 4d d0          	movslq -0x30(%rbp),%rcx
    14ab:	48 8d 05 8e 2c 02 00 	lea    0x22c8e(%rip),%rax        # 24140 <readMemoryByte.results>
    14b2:	8b 04 88             	mov    (%rax,%rcx,4),%eax
    14b5:	48 63 55 c8          	movslq -0x38(%rbp),%rdx
    14b9:	48 8d 0d 80 2c 02 00 	lea    0x22c80(%rip),%rcx        # 24140 <readMemoryByte.results>
    14c0:	3b 04 91             	cmp    (%rcx,%rdx,4),%eax
    14c3:	7c 06                	jl     14cb <readMemoryByte+0x2ab>
    14c5:	8b 45 d0             	mov    -0x30(%rbp),%eax
    14c8:	89 45 c8             	mov    %eax,-0x38(%rbp)
    14cb:	eb 00                	jmp    14cd <readMemoryByte+0x2ad>
    14cd:	eb 00                	jmp    14cf <readMemoryByte+0x2af>
    14cf:	8b 45 d0             	mov    -0x30(%rbp),%eax
    14d2:	83 c0 01             	add    $0x1,%eax
    14d5:	89 45 d0             	mov    %eax,-0x30(%rbp)
    14d8:	eb 8c                	jmp    1466 <readMemoryByte+0x246>
    14da:	48 63 4d cc          	movslq -0x34(%rbp),%rcx
    14de:	48 8d 05 5b 2c 02 00 	lea    0x22c5b(%rip),%rax        # 24140 <readMemoryByte.results>
    14e5:	8b 04 88             	mov    (%rax,%rcx,4),%eax
    14e8:	48 63 55 c8          	movslq -0x38(%rbp),%rdx
    14ec:	48 8d 0d 4d 2c 02 00 	lea    0x22c4d(%rip),%rcx        # 24140 <readMemoryByte.results>
    14f3:	8b 0c 91             	mov    (%rcx,%rdx,4),%ecx
    14f6:	d1 e1                	shl    %ecx
    14f8:	83 c1 05             	add    $0x5,%ecx
    14fb:	39 c8                	cmp    %ecx,%eax
    14fd:	7d 22                	jge    1521 <readMemoryByte+0x301>
    14ff:	48 63 4d cc          	movslq -0x34(%rbp),%rcx
    1503:	48 8d 05 36 2c 02 00 	lea    0x22c36(%rip),%rax        # 24140 <readMemoryByte.results>
    150a:	83 3c 88 02          	cmpl   $0x2,(%rax,%rcx,4)
    150e:	75 13                	jne    1523 <readMemoryByte+0x303>
    1510:	48 63 4d c8          	movslq -0x38(%rbp),%rcx
    1514:	48 8d 05 25 2c 02 00 	lea    0x22c25(%rip),%rax        # 24140 <readMemoryByte.results>
    151b:	83 3c 88 00          	cmpl   $0x0,(%rax,%rcx,4)
    151f:	75 02                	jne    1523 <readMemoryByte+0x303>
    1521:	eb 10                	jmp    1533 <readMemoryByte+0x313>
    1523:	eb 00                	jmp    1525 <readMemoryByte+0x305>
    1525:	8b 45 d4             	mov    -0x2c(%rbp),%eax
    1528:	83 c0 ff             	add    $0xffffffff,%eax
    152b:	89 45 d4             	mov    %eax,-0x2c(%rbp)
    152e:	e9 3f fd ff ff       	jmp    1272 <readMemoryByte+0x52>
    1533:	8b 45 c0             	mov    -0x40(%rbp),%eax
    1536:	33 05 04 2c 02 00    	xor    0x22c04(%rip),%eax        # 24140 <readMemoryByte.results>
    153c:	89 05 fe 2b 02 00    	mov    %eax,0x22bfe(%rip)        # 24140 <readMemoryByte.results>
    1542:	8b 45 cc             	mov    -0x34(%rbp),%eax
    1545:	88 c1                	mov    %al,%cl
    1547:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
    154b:	88 08                	mov    %cl,(%rax)
    154d:	48 63 4d cc          	movslq -0x34(%rbp),%rcx
    1551:	48 8d 05 e8 2b 02 00 	lea    0x22be8(%rip),%rax        # 24140 <readMemoryByte.results>
    1558:	8b 0c 88             	mov    (%rax,%rcx,4),%ecx
    155b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
    155f:	89 08                	mov    %ecx,(%rax)
    1561:	8b 45 c8             	mov    -0x38(%rbp),%eax
    1564:	88 c1                	mov    %al,%cl
    1566:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
    156a:	88 48 01             	mov    %cl,0x1(%rax)
    156d:	48 63 4d c8          	movslq -0x38(%rbp),%rcx
    1571:	48 8d 05 c8 2b 02 00 	lea    0x22bc8(%rip),%rax        # 24140 <readMemoryByte.results>
    1578:	8b 0c 88             	mov    (%rax,%rcx,4),%ecx
    157b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
    157f:	89 48 04             	mov    %ecx,0x4(%rax)
    1582:	48 81 c4 90 00 00 00 	add    $0x90,%rsp
    1589:	5d                   	pop    %rbp
    158a:	c3                   	ret    
    158b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000000001590 <main>:
    1590:	55                   	push   %rbp
    1591:	48 89 e5             	mov    %rsp,%rbp
    1594:	48 83 ec 50          	sub    $0x50,%rsp
    1598:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    159f:	89 7d f8             	mov    %edi,-0x8(%rbp)
    15a2:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
    15a6:	e8 c5 fa ff ff       	call   1070 <getchar@plt>
    15ab:	88 45 ef             	mov    %al,-0x11(%rbp)
    15ae:	0f be 45 ef          	movsbl -0x11(%rbp),%eax
    15b2:	83 f8 72             	cmp    $0x72,%eax
    15b5:	0f 85 ec 01 00 00    	jne    17a7 <main+0x217>
    15bb:	48 8b 35 4e 2b 00 00 	mov    0x2b4e(%rip),%rsi        # 4110 <secret>
    15c2:	48 8b 15 47 2b 00 00 	mov    0x2b47(%rip),%rdx        # 4110 <secret>
    15c9:	48 8d 3d 5d 0a 00 00 	lea    0xa5d(%rip),%rdi        # 202d <_IO_stdin_used+0x2d>
    15d0:	b0 00                	mov    $0x0,%al
    15d2:	e8 79 fa ff ff       	call   1050 <printf@plt>
    15d7:	48 8b 05 32 2b 00 00 	mov    0x2b32(%rip),%rax        # 4110 <secret>
    15de:	48 8d 0d 8b 2a 00 00 	lea    0x2a8b(%rip),%rcx        # 4070 <array1>
    15e5:	48 29 c8             	sub    %rcx,%rax
    15e8:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
    15ec:	48 8b 3d 1d 2b 00 00 	mov    0x2b1d(%rip),%rdi        # 4110 <secret>
    15f3:	e8 48 fa ff ff       	call   1040 <strlen@plt>
    15f8:	89 45 d4             	mov    %eax,-0x2c(%rbp)
    15fb:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
    1602:	00 
    1603:	48 81 7d c8 00 00 02 	cmpq   $0x20000,-0x38(%rbp)
    160a:	00 
    160b:	73 1d                	jae    162a <main+0x9a>
    160d:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
    1611:	48 8d 05 28 2b 00 00 	lea    0x2b28(%rip),%rax        # 4140 <array2>
    1618:	c6 04 08 01          	movb   $0x1,(%rax,%rcx,1)
    161c:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
    1620:	48 83 c0 01          	add    $0x1,%rax
    1624:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    1628:	eb d9                	jmp    1603 <main+0x73>
    162a:	83 7d f8 03          	cmpl   $0x3,-0x8(%rbp)
    162e:	75 5b                	jne    168b <main+0xfb>
    1630:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    1634:	48 8b 78 08          	mov    0x8(%rax),%rdi
    1638:	48 8d 55 e0          	lea    -0x20(%rbp),%rdx
    163c:	48 8d 35 0e 0a 00 00 	lea    0xa0e(%rip),%rsi        # 2051 <_IO_stdin_used+0x51>
    1643:	b0 00                	mov    $0x0,%al
    1645:	e8 36 fa ff ff       	call   1080 <__isoc99_sscanf@plt>
    164a:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
    164e:	48 8d 0d 1b 2a 00 00 	lea    0x2a1b(%rip),%rcx        # 4070 <array1>
    1655:	48 29 c8             	sub    %rcx,%rax
    1658:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
    165c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    1660:	48 8b 78 10          	mov    0x10(%rax),%rdi
    1664:	48 8d 35 e9 09 00 00 	lea    0x9e9(%rip),%rsi        # 2054 <_IO_stdin_used+0x54>
    166b:	48 8d 55 d4          	lea    -0x2c(%rbp),%rdx
    166f:	b0 00                	mov    $0x0,%al
    1671:	e8 0a fa ff ff       	call   1080 <__isoc99_sscanf@plt>
    1676:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
    167a:	8b 55 d4             	mov    -0x2c(%rbp),%edx
    167d:	48 8d 3d d3 09 00 00 	lea    0x9d3(%rip),%rdi        # 2057 <_IO_stdin_used+0x57>
    1684:	b0 00                	mov    $0x0,%al
    1686:	e8 c5 f9 ff ff       	call   1050 <printf@plt>
    168b:	8b 75 d4             	mov    -0x2c(%rbp),%esi
    168e:	48 8d 3d e5 09 00 00 	lea    0x9e5(%rip),%rdi        # 207a <_IO_stdin_used+0x7a>
    1695:	b0 00                	mov    $0x0,%al
    1697:	e8 b4 f9 ff ff       	call   1050 <printf@plt>
    169c:	8b 45 d4             	mov    -0x2c(%rbp),%eax
    169f:	83 c0 ff             	add    $0xffffffff,%eax
    16a2:	89 45 d4             	mov    %eax,-0x2c(%rbp)
    16a5:	83 f8 00             	cmp    $0x0,%eax
    16a8:	0f 8c f7 00 00 00    	jl     17a5 <main+0x215>
    16ae:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
    16b2:	48 8d 3d d4 09 00 00 	lea    0x9d4(%rip),%rdi        # 208d <_IO_stdin_used+0x8d>
    16b9:	b0 00                	mov    $0x0,%al
    16bb:	e8 90 f9 ff ff       	call   1050 <printf@plt>
    16c0:	48 8b 7d e0          	mov    -0x20(%rbp),%rdi
    16c4:	48 89 f8             	mov    %rdi,%rax
    16c7:	48 83 c0 01          	add    $0x1,%rax
    16cb:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
    16cf:	48 8d 75 d2          	lea    -0x2e(%rbp),%rsi
    16d3:	48 8d 55 d8          	lea    -0x28(%rbp),%rdx
    16d7:	e8 44 fb ff ff       	call   1220 <readMemoryByte>
    16dc:	8b 4d d8             	mov    -0x28(%rbp),%ecx
    16df:	8b 55 dc             	mov    -0x24(%rbp),%edx
    16e2:	d1 e2                	shl    %edx
    16e4:	48 8d 35 cf 09 00 00 	lea    0x9cf(%rip),%rsi        # 20ba <_IO_stdin_used+0xba>
    16eb:	48 8d 05 c0 09 00 00 	lea    0x9c0(%rip),%rax        # 20b2 <_IO_stdin_used+0xb2>
    16f2:	39 d1                	cmp    %edx,%ecx
    16f4:	48 0f 4d f0          	cmovge %rax,%rsi
    16f8:	48 8d 3d ae 09 00 00 	lea    0x9ae(%rip),%rdi        # 20ad <_IO_stdin_used+0xad>
    16ff:	b0 00                	mov    $0x0,%al
    1701:	e8 4a f9 ff ff       	call   1050 <printf@plt>
    1706:	0f b6 45 d2          	movzbl -0x2e(%rbp),%eax
    170a:	89 45 c4             	mov    %eax,-0x3c(%rbp)
    170d:	0f b6 45 d2          	movzbl -0x2e(%rbp),%eax
    1711:	83 f8 1f             	cmp    $0x1f,%eax
    1714:	7e 12                	jle    1728 <main+0x198>
    1716:	0f b6 45 d2          	movzbl -0x2e(%rbp),%eax
    171a:	83 f8 7f             	cmp    $0x7f,%eax
    171d:	7d 09                	jge    1728 <main+0x198>
    171f:	0f b6 45 d2          	movzbl -0x2e(%rbp),%eax
    1723:	89 45 c0             	mov    %eax,-0x40(%rbp)
    1726:	eb 0a                	jmp    1732 <main+0x1a2>
    1728:	b8 3f 00 00 00       	mov    $0x3f,%eax
    172d:	89 45 c0             	mov    %eax,-0x40(%rbp)
    1730:	eb 00                	jmp    1732 <main+0x1a2>
    1732:	8b 75 c4             	mov    -0x3c(%rbp),%esi
    1735:	8b 55 c0             	mov    -0x40(%rbp),%edx
    1738:	8b 4d d8             	mov    -0x28(%rbp),%ecx
    173b:	48 8d 3d 80 09 00 00 	lea    0x980(%rip),%rdi        # 20c2 <_IO_stdin_used+0xc2>
    1742:	b0 00                	mov    $0x0,%al
    1744:	e8 07 f9 ff ff       	call   1050 <printf@plt>
    1749:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
    174d:	7e 43                	jle    1792 <main+0x202>
    174f:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
    1753:	89 45 bc             	mov    %eax,-0x44(%rbp)
    1756:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
    175a:	83 f8 1f             	cmp    $0x1f,%eax
    175d:	7e 12                	jle    1771 <main+0x1e1>
    175f:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
    1763:	83 f8 7f             	cmp    $0x7f,%eax
    1766:	7d 09                	jge    1771 <main+0x1e1>
    1768:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
    176c:	89 45 b8             	mov    %eax,-0x48(%rbp)
    176f:	eb 0a                	jmp    177b <main+0x1eb>
    1771:	b8 3f 00 00 00       	mov    $0x3f,%eax
    1776:	89 45 b8             	mov    %eax,-0x48(%rbp)
    1779:	eb 00                	jmp    177b <main+0x1eb>
    177b:	8b 75 bc             	mov    -0x44(%rbp),%esi
    177e:	8b 55 b8             	mov    -0x48(%rbp),%edx
    1781:	8b 4d dc             	mov    -0x24(%rbp),%ecx
    1784:	48 8d 3d 4d 09 00 00 	lea    0x94d(%rip),%rdi        # 20d8 <_IO_stdin_used+0xd8>
    178b:	b0 00                	mov    $0x0,%al
    178d:	e8 be f8 ff ff       	call   1050 <printf@plt>
    1792:	48 8d 3d f2 08 00 00 	lea    0x8f2(%rip),%rdi        # 208b <_IO_stdin_used+0x8b>
    1799:	b0 00                	mov    $0x0,%al
    179b:	e8 b0 f8 ff ff       	call   1050 <printf@plt>
    17a0:	e9 f7 fe ff ff       	jmp    169c <main+0x10c>
    17a5:	eb 41                	jmp    17e8 <main+0x258>
    17a7:	0f be 45 ef          	movsbl -0x11(%rbp),%eax
    17ab:	83 f8 0a             	cmp    $0xa,%eax
    17ae:	75 05                	jne    17b5 <main+0x225>
    17b0:	e9 f1 fd ff ff       	jmp    15a6 <main+0x16>
    17b5:	0f be 45 ef          	movsbl -0x11(%rbp),%eax
    17b9:	83 f8 69             	cmp    $0x69,%eax
    17bc:	75 24                	jne    17e2 <main+0x252>
    17be:	b0 00                	mov    $0x0,%al
    17c0:	e8 6b f8 ff ff       	call   1030 <getpid@plt>
    17c5:	89 c2                	mov    %eax,%edx
    17c7:	48 8d 3d 2e 09 00 00 	lea    0x92e(%rip),%rdi        # 20fc <_IO_stdin_used+0xfc>
    17ce:	48 8d 35 bb f9 ff ff 	lea    -0x645(%rip),%rsi        # 1190 <check>
    17d5:	48 83 c6 21          	add    $0x21,%rsi
    17d9:	b0 00                	mov    $0x0,%al
    17db:	e8 70 f8 ff ff       	call   1050 <printf@plt>
    17e0:	eb 02                	jmp    17e4 <main+0x254>
    17e2:	eb 09                	jmp    17ed <main+0x25d>
    17e4:	eb 00                	jmp    17e6 <main+0x256>
    17e6:	eb 00                	jmp    17e8 <main+0x258>
    17e8:	e9 b9 fd ff ff       	jmp    15a6 <main+0x16>
    17ed:	31 c0                	xor    %eax,%eax
    17ef:	48 83 c4 50          	add    $0x50,%rsp
    17f3:	5d                   	pop    %rbp
    17f4:	c3                   	ret    

Disassembly of section .fini:

00000000000017f8 <_fini>:
    17f8:	f3 0f 1e fa          	endbr64 
    17fc:	48 83 ec 08          	sub    $0x8,%rsp
    1800:	48 83 c4 08          	add    $0x8,%rsp
    1804:	c3                   	ret    

spec_cl_o0.out      elf64-x86-64


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

0000000000001020 <getpid@plt-0x10>:
    1020:	ff 35 e2 2f 00 00    	push   0x2fe2(%rip)        # 4008 <_GLOBAL_OFFSET_TABLE_+0x8>
    1026:	ff 25 e4 2f 00 00    	jmp    *0x2fe4(%rip)        # 4010 <_GLOBAL_OFFSET_TABLE_+0x10>
    102c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000001030 <getpid@plt>:
    1030:	ff 25 e2 2f 00 00    	jmp    *0x2fe2(%rip)        # 4018 <getpid@GLIBC_2.2.5>
    1036:	68 00 00 00 00       	push   $0x0
    103b:	e9 e0 ff ff ff       	jmp    1020 <_init+0x20>

0000000000001040 <strlen@plt>:
    1040:	ff 25 da 2f 00 00    	jmp    *0x2fda(%rip)        # 4020 <strlen@GLIBC_2.2.5>
    1046:	68 01 00 00 00       	push   $0x1
    104b:	e9 d0 ff ff ff       	jmp    1020 <_init+0x20>

0000000000001050 <printf@plt>:
    1050:	ff 25 d2 2f 00 00    	jmp    *0x2fd2(%rip)        # 4028 <printf@GLIBC_2.2.5>
    1056:	68 02 00 00 00       	push   $0x2
    105b:	e9 c0 ff ff ff       	jmp    1020 <_init+0x20>

0000000000001060 <memcmp@plt>:
    1060:	ff 25 ca 2f 00 00    	jmp    *0x2fca(%rip)        # 4030 <memcmp@GLIBC_2.2.5>
    1066:	68 03 00 00 00       	push   $0x3
    106b:	e9 b0 ff ff ff       	jmp    1020 <_init+0x20>

0000000000001070 <getchar@plt>:
    1070:	ff 25 c2 2f 00 00    	jmp    *0x2fc2(%rip)        # 4038 <getchar@GLIBC_2.2.5>
    1076:	68 04 00 00 00       	push   $0x4
    107b:	e9 a0 ff ff ff       	jmp    1020 <_init+0x20>

0000000000001080 <__isoc99_sscanf@plt>:
    1080:	ff 25 ba 2f 00 00    	jmp    *0x2fba(%rip)        # 4040 <__isoc99_sscanf@GLIBC_2.7>
    1086:	68 05 00 00 00       	push   $0x5
    108b:	e9 90 ff ff ff       	jmp    1020 <_init+0x20>

Disassembly of section .plt.got:

0000000000001090 <__cxa_finalize@plt>:
    1090:	ff 25 62 2f 00 00    	jmp    *0x2f62(%rip)        # 3ff8 <__cxa_finalize@GLIBC_2.2.5>
    1096:	66 90                	xchg   %ax,%ax

Disassembly of section .text:

00000000000010a0 <_start>:
    10a0:	f3 0f 1e fa          	endbr64 
    10a4:	31 ed                	xor    %ebp,%ebp
    10a6:	49 89 d1             	mov    %rdx,%r9
    10a9:	5e                   	pop    %rsi
    10aa:	48 89 e2             	mov    %rsp,%rdx
    10ad:	48 83 e4 f0          	and    $0xfffffffffffffff0,%rsp
    10b1:	50                   	push   %rax
    10b2:	54                   	push   %rsp
    10b3:	45 31 c0             	xor    %r8d,%r8d
    10b6:	31 c9                	xor    %ecx,%ecx
    10b8:	48 8d 3d d1 04 00 00 	lea    0x4d1(%rip),%rdi        # 1590 <main>
    10bf:	ff 15 13 2f 00 00    	call   *0x2f13(%rip)        # 3fd8 <__libc_start_main@GLIBC_2.34>
    10c5:	f4                   	hlt    
    10c6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    10cd:	00 00 00 

00000000000010d0 <deregister_tm_clones>:
    10d0:	48 8d 3d 41 30 00 00 	lea    0x3041(%rip),%rdi        # 4118 <__TMC_END__>
    10d7:	48 8d 05 3a 30 00 00 	lea    0x303a(%rip),%rax        # 4118 <__TMC_END__>
    10de:	48 39 f8             	cmp    %rdi,%rax
    10e1:	74 15                	je     10f8 <deregister_tm_clones+0x28>
    10e3:	48 8b 05 f6 2e 00 00 	mov    0x2ef6(%rip),%rax        # 3fe0 <_ITM_deregisterTMCloneTable@Base>
    10ea:	48 85 c0             	test   %rax,%rax
    10ed:	74 09                	je     10f8 <deregister_tm_clones+0x28>
    10ef:	ff e0                	jmp    *%rax
    10f1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    10f8:	c3                   	ret    
    10f9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000001100 <register_tm_clones>:
    1100:	48 8d 3d 11 30 00 00 	lea    0x3011(%rip),%rdi        # 4118 <__TMC_END__>
    1107:	48 8d 35 0a 30 00 00 	lea    0x300a(%rip),%rsi        # 4118 <__TMC_END__>
    110e:	48 29 fe             	sub    %rdi,%rsi
    1111:	48 89 f0             	mov    %rsi,%rax
    1114:	48 c1 ee 3f          	shr    $0x3f,%rsi
    1118:	48 c1 f8 03          	sar    $0x3,%rax
    111c:	48 01 c6             	add    %rax,%rsi
    111f:	48 d1 fe             	sar    %rsi
    1122:	74 14                	je     1138 <register_tm_clones+0x38>
    1124:	48 8b 05 c5 2e 00 00 	mov    0x2ec5(%rip),%rax        # 3ff0 <_ITM_registerTMCloneTable@Base>
    112b:	48 85 c0             	test   %rax,%rax
    112e:	74 08                	je     1138 <register_tm_clones+0x38>
    1130:	ff e0                	jmp    *%rax
    1132:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    1138:	c3                   	ret    
    1139:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000001140 <__do_global_dtors_aux>:
    1140:	f3 0f 1e fa          	endbr64 
    1144:	80 3d d5 2f 00 00 00 	cmpb   $0x0,0x2fd5(%rip)        # 4120 <completed.0>
    114b:	75 2b                	jne    1178 <__do_global_dtors_aux+0x38>
    114d:	55                   	push   %rbp
    114e:	48 83 3d a2 2e 00 00 	cmpq   $0x0,0x2ea2(%rip)        # 3ff8 <__cxa_finalize@GLIBC_2.2.5>
    1155:	00 
    1156:	48 89 e5             	mov    %rsp,%rbp
    1159:	74 0c                	je     1167 <__do_global_dtors_aux+0x27>
    115b:	48 8b 3d f6 2e 00 00 	mov    0x2ef6(%rip),%rdi        # 4058 <__dso_handle>
    1162:	e8 29 ff ff ff       	call   1090 <__cxa_finalize@plt>
    1167:	e8 64 ff ff ff       	call   10d0 <deregister_tm_clones>
    116c:	c6 05 ad 2f 00 00 01 	movb   $0x1,0x2fad(%rip)        # 4120 <completed.0>
    1173:	5d                   	pop    %rbp
    1174:	c3                   	ret    
    1175:	0f 1f 00             	nopl   (%rax)
    1178:	c3                   	ret    
    1179:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000001180 <frame_dummy>:
    1180:	f3 0f 1e fa          	endbr64 
    1184:	e9 77 ff ff ff       	jmp    1100 <register_tm_clones>
    1189:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000001190 <check>:
    1190:	55                   	push   %rbp
    1191:	48 89 e5             	mov    %rsp,%rbp
    1194:	48 89 7d f0          	mov    %rdi,-0x10(%rbp)
    1198:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    119c:	8b 0d be 2e 00 00    	mov    0x2ebe(%rip),%ecx        # 4060 <array1_size>
    11a2:	48 63 c9             	movslq %ecx,%rcx
    11a5:	48 39 c8             	cmp    %rcx,%rax
    11a8:	73 09                	jae    11b3 <check+0x23>
    11aa:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)
    11b1:	eb 07                	jmp    11ba <check+0x2a>
    11b3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    11ba:	8b 45 fc             	mov    -0x4(%rbp),%eax
    11bd:	5d                   	pop    %rbp
    11be:	c3                   	ret    
    11bf:	90                   	nop

00000000000011c0 <victim_function>:
    11c0:	55                   	push   %rbp
    11c1:	48 89 e5             	mov    %rsp,%rbp
    11c4:	48 83 ec 10          	sub    $0x10,%rsp
    11c8:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
    11cc:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    11d0:	8b 0d 8a 2e 00 00    	mov    0x2e8a(%rip),%ecx        # 4060 <array1_size>
    11d6:	48 63 c9             	movslq %ecx,%rcx
    11d9:	48 39 c8             	cmp    %rcx,%rax
    11dc:	73 35                	jae    1213 <victim_function+0x53>
    11de:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
    11e2:	48 8d 05 87 2e 00 00 	lea    0x2e87(%rip),%rax        # 4070 <array1>
    11e9:	0f b6 04 08          	movzbl (%rax,%rcx,1),%eax
    11ed:	c1 e0 09             	shl    $0x9,%eax
    11f0:	48 98                	cltq   
    11f2:	48 8d 35 47 2f 00 00 	lea    0x2f47(%rip),%rsi        # 4140 <array2>
    11f9:	48 01 c6             	add    %rax,%rsi
    11fc:	48 8d 3d 2d 2f 00 00 	lea    0x2f2d(%rip),%rdi        # 4130 <temp>
    1203:	ba 01 00 00 00       	mov    $0x1,%edx
    1208:	e8 53 fe ff ff       	call   1060 <memcmp@plt>
    120d:	88 05 1d 2f 00 00    	mov    %al,0x2f1d(%rip)        # 4130 <temp>
    1213:	48 83 c4 10          	add    $0x10,%rsp
    1217:	5d                   	pop    %rbp
    1218:	c3                   	ret    
    1219:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000001220 <readMemoryByte>:
    1220:	55                   	push   %rbp
    1221:	48 89 e5             	mov    %rsp,%rbp
    1224:	48 81 ec 90 00 00 00 	sub    $0x90,%rsp
    122b:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
    122f:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
    1233:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    1237:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%rbp)
    123e:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%rbp)
    1245:	81 7d d0 00 01 00 00 	cmpl   $0x100,-0x30(%rbp)
    124c:	7d 1d                	jge    126b <readMemoryByte+0x4b>
    124e:	48 63 4d d0          	movslq -0x30(%rbp),%rcx
    1252:	48 8d 05 e7 2e 02 00 	lea    0x22ee7(%rip),%rax        # 24140 <readMemoryByte.results>
    1259:	c7 04 88 00 00 00 00 	movl   $0x0,(%rax,%rcx,4)
    1260:	8b 45 d0             	mov    -0x30(%rbp),%eax
    1263:	83 c0 01             	add    $0x1,%eax
    1266:	89 45 d0             	mov    %eax,-0x30(%rbp)
    1269:	eb da                	jmp    1245 <readMemoryByte+0x25>
    126b:	c7 45 d4 e7 03 00 00 	movl   $0x3e7,-0x2c(%rbp)
    1272:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
    1276:	0f 8e b7 02 00 00    	jle    1533 <readMemoryByte+0x313>
    127c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%rbp)
    1283:	81 7d d0 00 01 00 00 	cmpl   $0x100,-0x30(%rbp)
    128a:	7d 21                	jge    12ad <readMemoryByte+0x8d>
    128c:	8b 45 d0             	mov    -0x30(%rbp),%eax
    128f:	c1 e0 09             	shl    $0x9,%eax
    1292:	48 63 c8             	movslq %eax,%rcx
    1295:	48 8d 05 a4 2e 00 00 	lea    0x2ea4(%rip),%rax        # 4140 <array2>
    129c:	48 01 c8             	add    %rcx,%rax
    129f:	0f ae 38             	clflush (%rax)
    12a2:	8b 45 d0             	mov    -0x30(%rbp),%eax
    12a5:	83 c0 01             	add    $0x1,%eax
    12a8:	89 45 d0             	mov    %eax,-0x30(%rbp)
    12ab:	eb d6                	jmp    1283 <readMemoryByte+0x63>
    12ad:	8b 45 d4             	mov    -0x2c(%rbp),%eax
    12b0:	8b 0d aa 2d 00 00    	mov    0x2daa(%rip),%ecx        # 4060 <array1_size>
    12b6:	99                   	cltd   
    12b7:	f7 f9                	idiv   %ecx
    12b9:	48 63 c2             	movslq %edx,%rax
    12bc:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    12c0:	c7 45 cc 1d 00 00 00 	movl   $0x1d,-0x34(%rbp)
    12c7:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
    12cb:	0f 8c 82 00 00 00    	jl     1353 <readMemoryByte+0x133>
    12d1:	0f ae 3d 88 2d 00 00 	clflush 0x2d88(%rip)        # 4060 <array1_size>
    12d8:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%rbp)
    12df:	8b 45 94             	mov    -0x6c(%rbp),%eax
    12e2:	83 f8 64             	cmp    $0x64,%eax
    12e5:	7d 0d                	jge    12f4 <readMemoryByte+0xd4>
    12e7:	eb 00                	jmp    12e9 <readMemoryByte+0xc9>
    12e9:	8b 45 94             	mov    -0x6c(%rbp),%eax
    12ec:	83 c0 01             	add    $0x1,%eax
    12ef:	89 45 94             	mov    %eax,-0x6c(%rbp)
    12f2:	eb eb                	jmp    12df <readMemoryByte+0xbf>
    12f4:	8b 45 cc             	mov    -0x34(%rbp),%eax
    12f7:	b9 06 00 00 00       	mov    $0x6,%ecx
    12fc:	99                   	cltd   
    12fd:	f7 f9                	idiv   %ecx
    12ff:	89 d0                	mov    %edx,%eax
    1301:	83 e8 01             	sub    $0x1,%eax
    1304:	25 00 00 ff ff       	and    $0xffff0000,%eax
    1309:	48 98                	cltq   
    130b:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
    130f:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
    1313:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
    1317:	48 c1 e9 10          	shr    $0x10,%rcx
    131b:	48 09 c8             	or     %rcx,%rax
    131e:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
    1322:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
    1326:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
    132a:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
    132e:	48 33 55 b8          	xor    -0x48(%rbp),%rdx
    1332:	48 21 d1             	and    %rdx,%rcx
    1335:	48 31 c8             	xor    %rcx,%rax
    1338:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
    133c:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
    1340:	e8 7b fe ff ff       	call   11c0 <victim_function>
    1345:	8b 45 cc             	mov    -0x34(%rbp),%eax
    1348:	83 c0 ff             	add    $0xffffffff,%eax
    134b:	89 45 cc             	mov    %eax,-0x34(%rbp)
    134e:	e9 74 ff ff ff       	jmp    12c7 <readMemoryByte+0xa7>
    1353:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%rbp)
    135a:	81 7d d0 00 01 00 00 	cmpl   $0x100,-0x30(%rbp)
    1361:	0f 8d ea 00 00 00    	jge    1451 <readMemoryByte+0x231>
    1367:	69 45 d0 a7 00 00 00 	imul   $0xa7,-0x30(%rbp),%eax
    136e:	83 c0 0d             	add    $0xd,%eax
    1371:	25 ff 00 00 00       	and    $0xff,%eax
    1376:	89 45 c4             	mov    %eax,-0x3c(%rbp)
    1379:	8b 45 c4             	mov    -0x3c(%rbp),%eax
    137c:	c1 e0 09             	shl    $0x9,%eax
    137f:	48 63 c8             	movslq %eax,%rcx
    1382:	48 8d 05 b7 2d 00 00 	lea    0x2db7(%rip),%rax        # 4140 <array2>
    1389:	48 01 c8             	add    %rcx,%rax
    138c:	48 89 45 98          	mov    %rax,-0x68(%rbp)
    1390:	48 8d 45 c0          	lea    -0x40(%rbp),%rax
    1394:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    1398:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    139c:	48 89 45 80          	mov    %rax,-0x80(%rbp)
    13a0:	0f 01 f9             	rdtscp 
    13a3:	48 89 d6             	mov    %rdx,%rsi
    13a6:	89 ca                	mov    %ecx,%edx
    13a8:	48 8b 4d 80          	mov    -0x80(%rbp),%rcx
    13ac:	48 c1 e6 20          	shl    $0x20,%rsi
    13b0:	48 09 f0             	or     %rsi,%rax
    13b3:	89 11                	mov    %edx,(%rcx)
    13b5:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
    13b9:	48 8b 45 98          	mov    -0x68(%rbp),%rax
    13bd:	8a 00                	mov    (%rax),%al
    13bf:	0f b6 c0             	movzbl %al,%eax
    13c2:	89 45 c0             	mov    %eax,-0x40(%rbp)
    13c5:	48 8d 45 c0          	lea    -0x40(%rbp),%rax
    13c9:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    13cd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    13d1:	48 89 45 88          	mov    %rax,-0x78(%rbp)
    13d5:	0f 01 f9             	rdtscp 
    13d8:	48 89 d6             	mov    %rdx,%rsi
    13db:	89 ca                	mov    %ecx,%edx
    13dd:	48 8b 4d 88          	mov    -0x78(%rbp),%rcx
    13e1:	48 c1 e6 20          	shl    $0x20,%rsi
    13e5:	48 09 f0             	or     %rsi,%rax
    13e8:	89 11                	mov    %edx,(%rcx)
    13ea:	48 2b 45 a8          	sub    -0x58(%rbp),%rax
    13ee:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
    13f2:	48 83 7d a0 64       	cmpq   $0x64,-0x60(%rbp)
    13f7:	77 48                	ja     1441 <readMemoryByte+0x221>
    13f9:	8b 45 c4             	mov    -0x3c(%rbp),%eax
    13fc:	89 85 7c ff ff ff    	mov    %eax,-0x84(%rbp)
    1402:	8b 45 d4             	mov    -0x2c(%rbp),%eax
    1405:	8b 0d 55 2c 00 00    	mov    0x2c55(%rip),%ecx        # 4060 <array1_size>
    140b:	99                   	cltd   
    140c:	f7 f9                	idiv   %ecx
    140e:	8b 85 7c ff ff ff    	mov    -0x84(%rbp),%eax
    1414:	48 63 d2             	movslq %edx,%rdx
    1417:	48 8d 0d 52 2c 00 00 	lea    0x2c52(%rip),%rcx        # 4070 <array1>
    141e:	0f b6 0c 11          	movzbl (%rcx,%rdx,1),%ecx
    1422:	39 c8                	cmp    %ecx,%eax
    1424:	74 1b                	je     1441 <readMemoryByte+0x221>
    1426:	48 63 4d c4          	movslq -0x3c(%rbp),%rcx
    142a:	48 8d 05 0f 2d 02 00 	lea    0x22d0f(%rip),%rax        # 24140 <readMemoryByte.results>
    1431:	8b 14 88             	mov    (%rax,%rcx,4),%edx
    1434:	83 c2 01             	add    $0x1,%edx
    1437:	48 8d 05 02 2d 02 00 	lea    0x22d02(%rip),%rax        # 24140 <readMemoryByte.results>
    143e:	89 14 88             	mov    %edx,(%rax,%rcx,4)
    1441:	eb 00                	jmp    1443 <readMemoryByte+0x223>
    1443:	8b 45 d0             	mov    -0x30(%rbp),%eax
    1446:	83 c0 01             	add    $0x1,%eax
    1449:	89 45 d0             	mov    %eax,-0x30(%rbp)
    144c:	e9 09 ff ff ff       	jmp    135a <readMemoryByte+0x13a>
    1451:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%rbp)
    1458:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%rbp)
    145f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%rbp)
    1466:	81 7d d0 00 01 00 00 	cmpl   $0x100,-0x30(%rbp)
    146d:	7d 6b                	jge    14da <readMemoryByte+0x2ba>
    146f:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
    1473:	7c 1e                	jl     1493 <readMemoryByte+0x273>
    1475:	48 63 4d d0          	movslq -0x30(%rbp),%rcx
    1479:	48 8d 05 c0 2c 02 00 	lea    0x22cc0(%rip),%rax        # 24140 <readMemoryByte.results>
    1480:	8b 04 88             	mov    (%rax,%rcx,4),%eax
    1483:	48 63 55 cc          	movslq -0x34(%rbp),%rdx
    1487:	48 8d 0d b2 2c 02 00 	lea    0x22cb2(%rip),%rcx        # 24140 <readMemoryByte.results>
    148e:	3b 04 91             	cmp    (%rcx,%rdx,4),%eax
    1491:	7c 0e                	jl     14a1 <readMemoryByte+0x281>
    1493:	8b 45 cc             	mov    -0x34(%rbp),%eax
    1496:	89 45 c8             	mov    %eax,-0x38(%rbp)
    1499:	8b 45 d0             	mov    -0x30(%rbp),%eax
    149c:	89 45 cc             	mov    %eax,-0x34(%rbp)
    149f:	eb 2c                	jmp    14cd <readMemoryByte+0x2ad>
    14a1:	83 7d c8 00          	cmpl   $0x0,-0x38(%rbp)
    14a5:	7c 1e                	jl     14c5 <readMemoryByte+0x2a5>
    14a7:	48 63 4d d0          	movslq -0x30(%rbp),%rcx
    14ab:	48 8d 05 8e 2c 02 00 	lea    0x22c8e(%rip),%rax        # 24140 <readMemoryByte.results>
    14b2:	8b 04 88             	mov    (%rax,%rcx,4),%eax
    14b5:	48 63 55 c8          	movslq -0x38(%rbp),%rdx
    14b9:	48 8d 0d 80 2c 02 00 	lea    0x22c80(%rip),%rcx        # 24140 <readMemoryByte.results>
    14c0:	3b 04 91             	cmp    (%rcx,%rdx,4),%eax
    14c3:	7c 06                	jl     14cb <readMemoryByte+0x2ab>
    14c5:	8b 45 d0             	mov    -0x30(%rbp),%eax
    14c8:	89 45 c8             	mov    %eax,-0x38(%rbp)
    14cb:	eb 00                	jmp    14cd <readMemoryByte+0x2ad>
    14cd:	eb 00                	jmp    14cf <readMemoryByte+0x2af>
    14cf:	8b 45 d0             	mov    -0x30(%rbp),%eax
    14d2:	83 c0 01             	add    $0x1,%eax
    14d5:	89 45 d0             	mov    %eax,-0x30(%rbp)
    14d8:	eb 8c                	jmp    1466 <readMemoryByte+0x246>
    14da:	48 63 4d cc          	movslq -0x34(%rbp),%rcx
    14de:	48 8d 05 5b 2c 02 00 	lea    0x22c5b(%rip),%rax        # 24140 <readMemoryByte.results>
    14e5:	8b 04 88             	mov    (%rax,%rcx,4),%eax
    14e8:	48 63 55 c8          	movslq -0x38(%rbp),%rdx
    14ec:	48 8d 0d 4d 2c 02 00 	lea    0x22c4d(%rip),%rcx        # 24140 <readMemoryByte.results>
    14f3:	8b 0c 91             	mov    (%rcx,%rdx,4),%ecx
    14f6:	d1 e1                	shl    %ecx
    14f8:	83 c1 05             	add    $0x5,%ecx
    14fb:	39 c8                	cmp    %ecx,%eax
    14fd:	7d 22                	jge    1521 <readMemoryByte+0x301>
    14ff:	48 63 4d cc          	movslq -0x34(%rbp),%rcx
    1503:	48 8d 05 36 2c 02 00 	lea    0x22c36(%rip),%rax        # 24140 <readMemoryByte.results>
    150a:	83 3c 88 02          	cmpl   $0x2,(%rax,%rcx,4)
    150e:	75 13                	jne    1523 <readMemoryByte+0x303>
    1510:	48 63 4d c8          	movslq -0x38(%rbp),%rcx
    1514:	48 8d 05 25 2c 02 00 	lea    0x22c25(%rip),%rax        # 24140 <readMemoryByte.results>
    151b:	83 3c 88 00          	cmpl   $0x0,(%rax,%rcx,4)
    151f:	75 02                	jne    1523 <readMemoryByte+0x303>
    1521:	eb 10                	jmp    1533 <readMemoryByte+0x313>
    1523:	eb 00                	jmp    1525 <readMemoryByte+0x305>
    1525:	8b 45 d4             	mov    -0x2c(%rbp),%eax
    1528:	83 c0 ff             	add    $0xffffffff,%eax
    152b:	89 45 d4             	mov    %eax,-0x2c(%rbp)
    152e:	e9 3f fd ff ff       	jmp    1272 <readMemoryByte+0x52>
    1533:	8b 45 c0             	mov    -0x40(%rbp),%eax
    1536:	33 05 04 2c 02 00    	xor    0x22c04(%rip),%eax        # 24140 <readMemoryByte.results>
    153c:	89 05 fe 2b 02 00    	mov    %eax,0x22bfe(%rip)        # 24140 <readMemoryByte.results>
    1542:	8b 45 cc             	mov    -0x34(%rbp),%eax
    1545:	88 c1                	mov    %al,%cl
    1547:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
    154b:	88 08                	mov    %cl,(%rax)
    154d:	48 63 4d cc          	movslq -0x34(%rbp),%rcx
    1551:	48 8d 05 e8 2b 02 00 	lea    0x22be8(%rip),%rax        # 24140 <readMemoryByte.results>
    1558:	8b 0c 88             	mov    (%rax,%rcx,4),%ecx
    155b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
    155f:	89 08                	mov    %ecx,(%rax)
    1561:	8b 45 c8             	mov    -0x38(%rbp),%eax
    1564:	88 c1                	mov    %al,%cl
    1566:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
    156a:	88 48 01             	mov    %cl,0x1(%rax)
    156d:	48 63 4d c8          	movslq -0x38(%rbp),%rcx
    1571:	48 8d 05 c8 2b 02 00 	lea    0x22bc8(%rip),%rax        # 24140 <readMemoryByte.results>
    1578:	8b 0c 88             	mov    (%rax,%rcx,4),%ecx
    157b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
    157f:	89 48 04             	mov    %ecx,0x4(%rax)
    1582:	48 81 c4 90 00 00 00 	add    $0x90,%rsp
    1589:	5d                   	pop    %rbp
    158a:	c3                   	ret    
    158b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000000001590 <main>:
    1590:	55                   	push   %rbp
    1591:	48 89 e5             	mov    %rsp,%rbp
    1594:	48 83 ec 50          	sub    $0x50,%rsp
    1598:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    159f:	89 7d f8             	mov    %edi,-0x8(%rbp)
    15a2:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
    15a6:	e8 c5 fa ff ff       	call   1070 <getchar@plt>
    15ab:	88 45 ef             	mov    %al,-0x11(%rbp)
    15ae:	0f be 45 ef          	movsbl -0x11(%rbp),%eax
    15b2:	83 f8 72             	cmp    $0x72,%eax
    15b5:	0f 85 0b 02 00 00    	jne    17c6 <main+0x236>
    15bb:	48 8b 35 4e 2b 00 00 	mov    0x2b4e(%rip),%rsi        # 4110 <secret>
    15c2:	48 8b 15 47 2b 00 00 	mov    0x2b47(%rip),%rdx        # 4110 <secret>
    15c9:	48 8d 3d 5d 0a 00 00 	lea    0xa5d(%rip),%rdi        # 202d <_IO_stdin_used+0x2d>
    15d0:	b0 00                	mov    $0x0,%al
    15d2:	e8 79 fa ff ff       	call   1050 <printf@plt>
    15d7:	48 8b 05 32 2b 00 00 	mov    0x2b32(%rip),%rax        # 4110 <secret>
    15de:	48 8d 0d 8b 2a 00 00 	lea    0x2a8b(%rip),%rcx        # 4070 <array1>
    15e5:	48 29 c8             	sub    %rcx,%rax
    15e8:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
    15ec:	48 8b 3d 1d 2b 00 00 	mov    0x2b1d(%rip),%rdi        # 4110 <secret>
    15f3:	e8 48 fa ff ff       	call   1040 <strlen@plt>
    15f8:	89 45 d4             	mov    %eax,-0x2c(%rbp)
    15fb:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
    1602:	00 
    1603:	48 81 7d c8 00 00 02 	cmpq   $0x20000,-0x38(%rbp)
    160a:	00 
    160b:	73 1d                	jae    162a <main+0x9a>
    160d:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
    1611:	48 8d 05 28 2b 00 00 	lea    0x2b28(%rip),%rax        # 4140 <array2>
    1618:	c6 04 08 01          	movb   $0x1,(%rax,%rcx,1)
    161c:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
    1620:	48 83 c0 01          	add    $0x1,%rax
    1624:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    1628:	eb d9                	jmp    1603 <main+0x73>
    162a:	83 7d f8 03          	cmpl   $0x3,-0x8(%rbp)
    162e:	75 5b                	jne    168b <main+0xfb>
    1630:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    1634:	48 8b 78 08          	mov    0x8(%rax),%rdi
    1638:	48 8d 55 e0          	lea    -0x20(%rbp),%rdx
    163c:	48 8d 35 0e 0a 00 00 	lea    0xa0e(%rip),%rsi        # 2051 <_IO_stdin_used+0x51>
    1643:	b0 00                	mov    $0x0,%al
    1645:	e8 36 fa ff ff       	call   1080 <__isoc99_sscanf@plt>
    164a:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
    164e:	48 8d 0d 1b 2a 00 00 	lea    0x2a1b(%rip),%rcx        # 4070 <array1>
    1655:	48 29 c8             	sub    %rcx,%rax
    1658:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
    165c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    1660:	48 8b 78 10          	mov    0x10(%rax),%rdi
    1664:	48 8d 35 e9 09 00 00 	lea    0x9e9(%rip),%rsi        # 2054 <_IO_stdin_used+0x54>
    166b:	48 8d 55 d4          	lea    -0x2c(%rbp),%rdx
    166f:	b0 00                	mov    $0x0,%al
    1671:	e8 0a fa ff ff       	call   1080 <__isoc99_sscanf@plt>
    1676:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
    167a:	8b 55 d4             	mov    -0x2c(%rbp),%edx
    167d:	48 8d 3d d3 09 00 00 	lea    0x9d3(%rip),%rdi        # 2057 <_IO_stdin_used+0x57>
    1684:	b0 00                	mov    $0x0,%al
    1686:	e8 c5 f9 ff ff       	call   1050 <printf@plt>
    168b:	8b 75 d4             	mov    -0x2c(%rbp),%esi
    168e:	48 8d 3d e5 09 00 00 	lea    0x9e5(%rip),%rdi        # 207a <_IO_stdin_used+0x7a>
    1695:	b0 00                	mov    $0x0,%al
    1697:	e8 b4 f9 ff ff       	call   1050 <printf@plt>
    169c:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%rbp)
    16a3:	8b 45 d4             	mov    -0x2c(%rbp),%eax
    16a6:	83 c0 ff             	add    $0xffffffff,%eax
    16a9:	89 45 d4             	mov    %eax,-0x2c(%rbp)
    16ac:	83 f8 00             	cmp    $0x0,%eax
    16af:	0f 8c 0f 01 00 00    	jl     17c4 <main+0x234>
    16b5:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
    16b9:	48 8b 05 50 2a 00 00 	mov    0x2a50(%rip),%rax        # 4110 <secret>
    16c0:	48 63 4d c4          	movslq -0x3c(%rbp),%rcx
    16c4:	0f be 14 08          	movsbl (%rax,%rcx,1),%edx
    16c8:	48 8d 3d be 09 00 00 	lea    0x9be(%rip),%rdi        # 208d <_IO_stdin_used+0x8d>
    16cf:	b0 00                	mov    $0x0,%al
    16d1:	e8 7a f9 ff ff       	call   1050 <printf@plt>
    16d6:	8b 45 c4             	mov    -0x3c(%rbp),%eax
    16d9:	83 c0 01             	add    $0x1,%eax
    16dc:	89 45 c4             	mov    %eax,-0x3c(%rbp)
    16df:	48 8b 7d e0          	mov    -0x20(%rbp),%rdi
    16e3:	48 89 f8             	mov    %rdi,%rax
    16e6:	48 83 c0 01          	add    $0x1,%rax
    16ea:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
    16ee:	48 8d 75 d2          	lea    -0x2e(%rbp),%rsi
    16f2:	48 8d 55 d8          	lea    -0x28(%rbp),%rdx
    16f6:	e8 25 fb ff ff       	call   1220 <readMemoryByte>
    16fb:	8b 4d d8             	mov    -0x28(%rbp),%ecx
    16fe:	8b 55 dc             	mov    -0x24(%rbp),%edx
    1701:	d1 e2                	shl    %edx
    1703:	48 8d 35 b9 09 00 00 	lea    0x9b9(%rip),%rsi        # 20c3 <_IO_stdin_used+0xc3>
    170a:	48 8d 05 aa 09 00 00 	lea    0x9aa(%rip),%rax        # 20bb <_IO_stdin_used+0xbb>
    1711:	39 d1                	cmp    %edx,%ecx
    1713:	48 0f 4d f0          	cmovge %rax,%rsi
    1717:	48 8d 3d 98 09 00 00 	lea    0x998(%rip),%rdi        # 20b6 <_IO_stdin_used+0xb6>
    171e:	b0 00                	mov    $0x0,%al
    1720:	e8 2b f9 ff ff       	call   1050 <printf@plt>
    1725:	0f b6 45 d2          	movzbl -0x2e(%rbp),%eax
    1729:	89 45 c0             	mov    %eax,-0x40(%rbp)
    172c:	0f b6 45 d2          	movzbl -0x2e(%rbp),%eax
    1730:	83 f8 1f             	cmp    $0x1f,%eax
    1733:	7e 12                	jle    1747 <main+0x1b7>
    1735:	0f b6 45 d2          	movzbl -0x2e(%rbp),%eax
    1739:	83 f8 7f             	cmp    $0x7f,%eax
    173c:	7d 09                	jge    1747 <main+0x1b7>
    173e:	0f b6 45 d2          	movzbl -0x2e(%rbp),%eax
    1742:	89 45 bc             	mov    %eax,-0x44(%rbp)
    1745:	eb 0a                	jmp    1751 <main+0x1c1>
    1747:	b8 3f 00 00 00       	mov    $0x3f,%eax
    174c:	89 45 bc             	mov    %eax,-0x44(%rbp)
    174f:	eb 00                	jmp    1751 <main+0x1c1>
    1751:	8b 75 c0             	mov    -0x40(%rbp),%esi
    1754:	8b 55 bc             	mov    -0x44(%rbp),%edx
    1757:	8b 4d d8             	mov    -0x28(%rbp),%ecx
    175a:	48 8d 3d 6a 09 00 00 	lea    0x96a(%rip),%rdi        # 20cb <_IO_stdin_used+0xcb>
    1761:	b0 00                	mov    $0x0,%al
    1763:	e8 e8 f8 ff ff       	call   1050 <printf@plt>
    1768:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
    176c:	7e 43                	jle    17b1 <main+0x221>
    176e:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
    1772:	89 45 b8             	mov    %eax,-0x48(%rbp)
    1775:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
    1779:	83 f8 1f             	cmp    $0x1f,%eax
    177c:	7e 12                	jle    1790 <main+0x200>
    177e:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
    1782:	83 f8 7f             	cmp    $0x7f,%eax
    1785:	7d 09                	jge    1790 <main+0x200>
    1787:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
    178b:	89 45 b4             	mov    %eax,-0x4c(%rbp)
    178e:	eb 0a                	jmp    179a <main+0x20a>
    1790:	b8 3f 00 00 00       	mov    $0x3f,%eax
    1795:	89 45 b4             	mov    %eax,-0x4c(%rbp)
    1798:	eb 00                	jmp    179a <main+0x20a>
    179a:	8b 75 b8             	mov    -0x48(%rbp),%esi
    179d:	8b 55 b4             	mov    -0x4c(%rbp),%edx
    17a0:	8b 4d dc             	mov    -0x24(%rbp),%ecx
    17a3:	48 8d 3d 37 09 00 00 	lea    0x937(%rip),%rdi        # 20e1 <_IO_stdin_used+0xe1>
    17aa:	b0 00                	mov    $0x0,%al
    17ac:	e8 9f f8 ff ff       	call   1050 <printf@plt>
    17b1:	48 8d 3d d3 08 00 00 	lea    0x8d3(%rip),%rdi        # 208b <_IO_stdin_used+0x8b>
    17b8:	b0 00                	mov    $0x0,%al
    17ba:	e8 91 f8 ff ff       	call   1050 <printf@plt>
    17bf:	e9 df fe ff ff       	jmp    16a3 <main+0x113>
    17c4:	eb 41                	jmp    1807 <main+0x277>
    17c6:	0f be 45 ef          	movsbl -0x11(%rbp),%eax
    17ca:	83 f8 0a             	cmp    $0xa,%eax
    17cd:	75 05                	jne    17d4 <main+0x244>
    17cf:	e9 d2 fd ff ff       	jmp    15a6 <main+0x16>
    17d4:	0f be 45 ef          	movsbl -0x11(%rbp),%eax
    17d8:	83 f8 69             	cmp    $0x69,%eax
    17db:	75 24                	jne    1801 <main+0x271>
    17dd:	b0 00                	mov    $0x0,%al
    17df:	e8 4c f8 ff ff       	call   1030 <getpid@plt>
    17e4:	89 c2                	mov    %eax,%edx
    17e6:	48 8d 3d 18 09 00 00 	lea    0x918(%rip),%rdi        # 2105 <_IO_stdin_used+0x105>
    17ed:	48 8d 35 9c f9 ff ff 	lea    -0x664(%rip),%rsi        # 1190 <check>
    17f4:	48 83 c6 21          	add    $0x21,%rsi
    17f8:	b0 00                	mov    $0x0,%al
    17fa:	e8 51 f8 ff ff       	call   1050 <printf@plt>
    17ff:	eb 02                	jmp    1803 <main+0x273>
    1801:	eb 09                	jmp    180c <main+0x27c>
    1803:	eb 00                	jmp    1805 <main+0x275>
    1805:	eb 00                	jmp    1807 <main+0x277>
    1807:	e9 9a fd ff ff       	jmp    15a6 <main+0x16>
    180c:	31 c0                	xor    %eax,%eax
    180e:	48 83 c4 50          	add    $0x50,%rsp
    1812:	5d                   	pop    %rbp
    1813:	c3                   	ret    

Disassembly of section .fini:

0000000000001814 <_fini>:
    1814:	f3 0f 1e fa          	endbr64 
    1818:	48 83 ec 08          	sub    $0x8,%rsp
    181c:	48 83 c4 08          	add    $0x8,%rsp
    1820:	c3                   	ret    
