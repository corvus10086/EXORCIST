
spec_cl_o0.out：     文件格式 elf64-x86-64


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

0000000000001060 <getchar@plt>:
    1060:	ff 25 ca 2f 00 00    	jmp    *0x2fca(%rip)        # 4030 <getchar@GLIBC_2.2.5>
    1066:	68 03 00 00 00       	push   $0x3
    106b:	e9 b0 ff ff ff       	jmp    1020 <_init+0x20>

0000000000001070 <__isoc99_sscanf@plt>:
    1070:	ff 25 c2 2f 00 00    	jmp    *0x2fc2(%rip)        # 4038 <__isoc99_sscanf@GLIBC_2.7>
    1076:	68 04 00 00 00       	push   $0x4
    107b:	e9 a0 ff ff ff       	jmp    1020 <_init+0x20>

Disassembly of section .plt.got:

0000000000001080 <__cxa_finalize@plt>:
    1080:	ff 25 72 2f 00 00    	jmp    *0x2f72(%rip)        # 3ff8 <__cxa_finalize@GLIBC_2.2.5>
    1086:	66 90                	xchg   %ax,%ax

Disassembly of section .text:

0000000000001090 <_start>:
    1090:	f3 0f 1e fa          	endbr64 
    1094:	31 ed                	xor    %ebp,%ebp
    1096:	49 89 d1             	mov    %rdx,%r9
    1099:	5e                   	pop    %rsi
    109a:	48 89 e2             	mov    %rsp,%rdx
    109d:	48 83 e4 f0          	and    $0xfffffffffffffff0,%rsp
    10a1:	50                   	push   %rax
    10a2:	54                   	push   %rsp
    10a3:	45 31 c0             	xor    %r8d,%r8d
    10a6:	31 c9                	xor    %ecx,%ecx
    10a8:	48 8d 3d c1 04 00 00 	lea    0x4c1(%rip),%rdi        # 1570 <main>
    10af:	ff 15 23 2f 00 00    	call   *0x2f23(%rip)        # 3fd8 <__libc_start_main@GLIBC_2.34>
    10b5:	f4                   	hlt    
    10b6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    10bd:	00 00 00 

00000000000010c0 <deregister_tm_clones>:
    10c0:	48 8d 3d 41 30 02 00 	lea    0x23041(%rip),%rdi        # 24108 <__TMC_END__>
    10c7:	48 8d 05 3a 30 02 00 	lea    0x2303a(%rip),%rax        # 24108 <__TMC_END__>
    10ce:	48 39 f8             	cmp    %rdi,%rax
    10d1:	74 15                	je     10e8 <deregister_tm_clones+0x28>
    10d3:	48 8b 05 06 2f 00 00 	mov    0x2f06(%rip),%rax        # 3fe0 <_ITM_deregisterTMCloneTable@Base>
    10da:	48 85 c0             	test   %rax,%rax
    10dd:	74 09                	je     10e8 <deregister_tm_clones+0x28>
    10df:	ff e0                	jmp    *%rax
    10e1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    10e8:	c3                   	ret    
    10e9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

00000000000010f0 <register_tm_clones>:
    10f0:	48 8d 3d 11 30 02 00 	lea    0x23011(%rip),%rdi        # 24108 <__TMC_END__>
    10f7:	48 8d 35 0a 30 02 00 	lea    0x2300a(%rip),%rsi        # 24108 <__TMC_END__>
    10fe:	48 29 fe             	sub    %rdi,%rsi
    1101:	48 89 f0             	mov    %rsi,%rax
    1104:	48 c1 ee 3f          	shr    $0x3f,%rsi
    1108:	48 c1 f8 03          	sar    $0x3,%rax
    110c:	48 01 c6             	add    %rax,%rsi
    110f:	48 d1 fe             	sar    %rsi
    1112:	74 14                	je     1128 <register_tm_clones+0x38>
    1114:	48 8b 05 d5 2e 00 00 	mov    0x2ed5(%rip),%rax        # 3ff0 <_ITM_registerTMCloneTable@Base>
    111b:	48 85 c0             	test   %rax,%rax
    111e:	74 08                	je     1128 <register_tm_clones+0x38>
    1120:	ff e0                	jmp    *%rax
    1122:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    1128:	c3                   	ret    
    1129:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000001130 <__do_global_dtors_aux>:
    1130:	f3 0f 1e fa          	endbr64 
    1134:	80 3d d5 2f 02 00 00 	cmpb   $0x0,0x22fd5(%rip)        # 24110 <completed.0>
    113b:	75 2b                	jne    1168 <__do_global_dtors_aux+0x38>
    113d:	55                   	push   %rbp
    113e:	48 83 3d b2 2e 00 00 	cmpq   $0x0,0x2eb2(%rip)        # 3ff8 <__cxa_finalize@GLIBC_2.2.5>
    1145:	00 
    1146:	48 89 e5             	mov    %rsp,%rbp
    1149:	74 0c                	je     1157 <__do_global_dtors_aux+0x27>
    114b:	48 8b 3d f6 2e 00 00 	mov    0x2ef6(%rip),%rdi        # 4048 <__dso_handle>
    1152:	e8 29 ff ff ff       	call   1080 <__cxa_finalize@plt>
    1157:	e8 64 ff ff ff       	call   10c0 <deregister_tm_clones>
    115c:	c6 05 ad 2f 02 00 01 	movb   $0x1,0x22fad(%rip)        # 24110 <completed.0>
    1163:	5d                   	pop    %rbp
    1164:	c3                   	ret    
    1165:	0f 1f 00             	nopl   (%rax)
    1168:	c3                   	ret    
    1169:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000001170 <frame_dummy>:
    1170:	f3 0f 1e fa          	endbr64 
    1174:	e9 77 ff ff ff       	jmp    10f0 <register_tm_clones>
    1179:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000001180 <check>:
    1180:	55                   	push   %rbp
    1181:	48 89 e5             	mov    %rsp,%rbp
    1184:	48 89 7d f0          	mov    %rdi,-0x10(%rbp)
    1188:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    118c:	8b 0d be 2e 00 00    	mov    0x2ebe(%rip),%ecx        # 4050 <array1_size>
    1192:	48 63 c9             	movslq %ecx,%rcx
    1195:	48 39 c8             	cmp    %rcx,%rax
    1198:	73 09                	jae    11a3 <check+0x23>
    119a:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)
    11a1:	eb 07                	jmp    11aa <check+0x2a>
    11a3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    11aa:	8b 45 fc             	mov    -0x4(%rbp),%eax
    11ad:	5d                   	pop    %rbp
    11ae:	c3                   	ret    
    11af:	90                   	nop

00000000000011b0 <victim_function>:
    11b0:	55                   	push   %rbp
    11b1:	48 89 e5             	mov    %rsp,%rbp
    11b4:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
    11b8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    11bc:	8b 0d 8e 2e 00 00    	mov    0x2e8e(%rip),%ecx        # 4050 <array1_size>
    11c2:	48 63 c9             	movslq %ecx,%rcx
    11c5:	48 39 c8             	cmp    %rcx,%rax
    11c8:	73 2f                	jae    11f9 <victim_function+0x49>
    11ca:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
    11ce:	48 8d 05 8b 2e 00 00 	lea    0x2e8b(%rip),%rax        # 4060 <array1>
    11d5:	0f b6 04 08          	movzbl (%rax,%rcx,1),%eax
    11d9:	c1 e0 09             	shl    $0x9,%eax
    11dc:	48 63 c8             	movslq %eax,%rcx
    11df:	48 8d 05 1a 2f 00 00 	lea    0x2f1a(%rip),%rax        # 4100 <array2>
    11e6:	0f b6 0c 08          	movzbl (%rax,%rcx,1),%ecx
    11ea:	0f b6 05 2f 2f 02 00 	movzbl 0x22f2f(%rip),%eax        # 24120 <temp>
    11f1:	21 c8                	and    %ecx,%eax
    11f3:	88 05 27 2f 02 00    	mov    %al,0x22f27(%rip)        # 24120 <temp>
    11f9:	5d                   	pop    %rbp
    11fa:	c3                   	ret    
    11fb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000000001200 <readMemoryByte>:
    1200:	55                   	push   %rbp
    1201:	48 89 e5             	mov    %rsp,%rbp
    1204:	48 81 ec 90 00 00 00 	sub    $0x90,%rsp
    120b:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
    120f:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
    1213:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    1217:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%rbp)
    121e:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%rbp)
    1225:	81 7d d0 00 01 00 00 	cmpl   $0x100,-0x30(%rbp)
    122c:	7d 1d                	jge    124b <readMemoryByte+0x4b>
    122e:	48 63 4d d0          	movslq -0x30(%rbp),%rcx
    1232:	48 8d 05 f7 2e 02 00 	lea    0x22ef7(%rip),%rax        # 24130 <readMemoryByte.results>
    1239:	c7 04 88 00 00 00 00 	movl   $0x0,(%rax,%rcx,4)
    1240:	8b 45 d0             	mov    -0x30(%rbp),%eax
    1243:	83 c0 01             	add    $0x1,%eax
    1246:	89 45 d0             	mov    %eax,-0x30(%rbp)
    1249:	eb da                	jmp    1225 <readMemoryByte+0x25>
    124b:	c7 45 d4 e7 03 00 00 	movl   $0x3e7,-0x2c(%rbp)
    1252:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
    1256:	0f 8e b7 02 00 00    	jle    1513 <readMemoryByte+0x313>
    125c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%rbp)
    1263:	81 7d d0 00 01 00 00 	cmpl   $0x100,-0x30(%rbp)
    126a:	7d 21                	jge    128d <readMemoryByte+0x8d>
    126c:	8b 45 d0             	mov    -0x30(%rbp),%eax
    126f:	c1 e0 09             	shl    $0x9,%eax
    1272:	48 63 c8             	movslq %eax,%rcx
    1275:	48 8d 05 84 2e 00 00 	lea    0x2e84(%rip),%rax        # 4100 <array2>
    127c:	48 01 c8             	add    %rcx,%rax
    127f:	0f ae 38             	clflush (%rax)
    1282:	8b 45 d0             	mov    -0x30(%rbp),%eax
    1285:	83 c0 01             	add    $0x1,%eax
    1288:	89 45 d0             	mov    %eax,-0x30(%rbp)
    128b:	eb d6                	jmp    1263 <readMemoryByte+0x63>
    128d:	8b 45 d4             	mov    -0x2c(%rbp),%eax
    1290:	8b 0d ba 2d 00 00    	mov    0x2dba(%rip),%ecx        # 4050 <array1_size>
    1296:	99                   	cltd   
    1297:	f7 f9                	idiv   %ecx
    1299:	48 63 c2             	movslq %edx,%rax
    129c:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    12a0:	c7 45 cc 1d 00 00 00 	movl   $0x1d,-0x34(%rbp)
    12a7:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
    12ab:	0f 8c 82 00 00 00    	jl     1333 <readMemoryByte+0x133>
    12b1:	0f ae 3d 98 2d 00 00 	clflush 0x2d98(%rip)        # 4050 <array1_size>
    12b8:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%rbp)
    12bf:	8b 45 94             	mov    -0x6c(%rbp),%eax
    12c2:	83 f8 64             	cmp    $0x64,%eax
    12c5:	7d 0d                	jge    12d4 <readMemoryByte+0xd4>
    12c7:	eb 00                	jmp    12c9 <readMemoryByte+0xc9>
    12c9:	8b 45 94             	mov    -0x6c(%rbp),%eax
    12cc:	83 c0 01             	add    $0x1,%eax
    12cf:	89 45 94             	mov    %eax,-0x6c(%rbp)
    12d2:	eb eb                	jmp    12bf <readMemoryByte+0xbf>
    12d4:	8b 45 cc             	mov    -0x34(%rbp),%eax
    12d7:	b9 06 00 00 00       	mov    $0x6,%ecx
    12dc:	99                   	cltd   
    12dd:	f7 f9                	idiv   %ecx
    12df:	89 d0                	mov    %edx,%eax
    12e1:	83 e8 01             	sub    $0x1,%eax
    12e4:	25 00 00 ff ff       	and    $0xffff0000,%eax
    12e9:	48 98                	cltq   
    12eb:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
    12ef:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
    12f3:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
    12f7:	48 c1 e9 10          	shr    $0x10,%rcx
    12fb:	48 09 c8             	or     %rcx,%rax
    12fe:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
    1302:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
    1306:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
    130a:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
    130e:	48 33 55 b8          	xor    -0x48(%rbp),%rdx
    1312:	48 21 d1             	and    %rdx,%rcx
    1315:	48 31 c8             	xor    %rcx,%rax
    1318:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
    131c:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
    1320:	e8 8b fe ff ff       	call   11b0 <victim_function>
    1325:	8b 45 cc             	mov    -0x34(%rbp),%eax
    1328:	83 c0 ff             	add    $0xffffffff,%eax
    132b:	89 45 cc             	mov    %eax,-0x34(%rbp)
    132e:	e9 74 ff ff ff       	jmp    12a7 <readMemoryByte+0xa7>
    1333:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%rbp)
    133a:	81 7d d0 00 01 00 00 	cmpl   $0x100,-0x30(%rbp)
    1341:	0f 8d ea 00 00 00    	jge    1431 <readMemoryByte+0x231>
    1347:	69 45 d0 a7 00 00 00 	imul   $0xa7,-0x30(%rbp),%eax
    134e:	83 c0 0d             	add    $0xd,%eax
    1351:	25 ff 00 00 00       	and    $0xff,%eax
    1356:	89 45 c4             	mov    %eax,-0x3c(%rbp)
    1359:	8b 45 c4             	mov    -0x3c(%rbp),%eax
    135c:	c1 e0 09             	shl    $0x9,%eax
    135f:	48 63 c8             	movslq %eax,%rcx
    1362:	48 8d 05 97 2d 00 00 	lea    0x2d97(%rip),%rax        # 4100 <array2>
    1369:	48 01 c8             	add    %rcx,%rax
    136c:	48 89 45 98          	mov    %rax,-0x68(%rbp)
    1370:	48 8d 45 c0          	lea    -0x40(%rbp),%rax
    1374:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    1378:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    137c:	48 89 45 80          	mov    %rax,-0x80(%rbp)
    1380:	0f 01 f9             	rdtscp 
    1383:	48 89 d6             	mov    %rdx,%rsi
    1386:	89 ca                	mov    %ecx,%edx
    1388:	48 8b 4d 80          	mov    -0x80(%rbp),%rcx
    138c:	48 c1 e6 20          	shl    $0x20,%rsi
    1390:	48 09 f0             	or     %rsi,%rax
    1393:	89 11                	mov    %edx,(%rcx)
    1395:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
    1399:	48 8b 45 98          	mov    -0x68(%rbp),%rax
    139d:	8a 00                	mov    (%rax),%al
    139f:	0f b6 c0             	movzbl %al,%eax
    13a2:	89 45 c0             	mov    %eax,-0x40(%rbp)
    13a5:	48 8d 45 c0          	lea    -0x40(%rbp),%rax
    13a9:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    13ad:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    13b1:	48 89 45 88          	mov    %rax,-0x78(%rbp)
    13b5:	0f 01 f9             	rdtscp 
    13b8:	48 89 d6             	mov    %rdx,%rsi
    13bb:	89 ca                	mov    %ecx,%edx
    13bd:	48 8b 4d 88          	mov    -0x78(%rbp),%rcx
    13c1:	48 c1 e6 20          	shl    $0x20,%rsi
    13c5:	48 09 f0             	or     %rsi,%rax
    13c8:	89 11                	mov    %edx,(%rcx)
    13ca:	48 2b 45 a8          	sub    -0x58(%rbp),%rax
    13ce:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
    13d2:	48 83 7d a0 32       	cmpq   $0x32,-0x60(%rbp)
    13d7:	77 48                	ja     1421 <readMemoryByte+0x221>
    13d9:	8b 45 c4             	mov    -0x3c(%rbp),%eax
    13dc:	89 85 7c ff ff ff    	mov    %eax,-0x84(%rbp)
    13e2:	8b 45 d4             	mov    -0x2c(%rbp),%eax
    13e5:	8b 0d 65 2c 00 00    	mov    0x2c65(%rip),%ecx        # 4050 <array1_size>
    13eb:	99                   	cltd   
    13ec:	f7 f9                	idiv   %ecx
    13ee:	8b 85 7c ff ff ff    	mov    -0x84(%rbp),%eax
    13f4:	48 63 d2             	movslq %edx,%rdx
    13f7:	48 8d 0d 62 2c 00 00 	lea    0x2c62(%rip),%rcx        # 4060 <array1>
    13fe:	0f b6 0c 11          	movzbl (%rcx,%rdx,1),%ecx
    1402:	39 c8                	cmp    %ecx,%eax
    1404:	74 1b                	je     1421 <readMemoryByte+0x221>
    1406:	48 63 4d c4          	movslq -0x3c(%rbp),%rcx
    140a:	48 8d 05 1f 2d 02 00 	lea    0x22d1f(%rip),%rax        # 24130 <readMemoryByte.results>
    1411:	8b 14 88             	mov    (%rax,%rcx,4),%edx
    1414:	83 c2 01             	add    $0x1,%edx
    1417:	48 8d 05 12 2d 02 00 	lea    0x22d12(%rip),%rax        # 24130 <readMemoryByte.results>
    141e:	89 14 88             	mov    %edx,(%rax,%rcx,4)
    1421:	eb 00                	jmp    1423 <readMemoryByte+0x223>
    1423:	8b 45 d0             	mov    -0x30(%rbp),%eax
    1426:	83 c0 01             	add    $0x1,%eax
    1429:	89 45 d0             	mov    %eax,-0x30(%rbp)
    142c:	e9 09 ff ff ff       	jmp    133a <readMemoryByte+0x13a>
    1431:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%rbp)
    1438:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%rbp)
    143f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%rbp)
    1446:	81 7d d0 00 01 00 00 	cmpl   $0x100,-0x30(%rbp)
    144d:	7d 6b                	jge    14ba <readMemoryByte+0x2ba>
    144f:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
    1453:	7c 1e                	jl     1473 <readMemoryByte+0x273>
    1455:	48 63 4d d0          	movslq -0x30(%rbp),%rcx
    1459:	48 8d 05 d0 2c 02 00 	lea    0x22cd0(%rip),%rax        # 24130 <readMemoryByte.results>
    1460:	8b 04 88             	mov    (%rax,%rcx,4),%eax
    1463:	48 63 55 cc          	movslq -0x34(%rbp),%rdx
    1467:	48 8d 0d c2 2c 02 00 	lea    0x22cc2(%rip),%rcx        # 24130 <readMemoryByte.results>
    146e:	3b 04 91             	cmp    (%rcx,%rdx,4),%eax
    1471:	7c 0e                	jl     1481 <readMemoryByte+0x281>
    1473:	8b 45 cc             	mov    -0x34(%rbp),%eax
    1476:	89 45 c8             	mov    %eax,-0x38(%rbp)
    1479:	8b 45 d0             	mov    -0x30(%rbp),%eax
    147c:	89 45 cc             	mov    %eax,-0x34(%rbp)
    147f:	eb 2c                	jmp    14ad <readMemoryByte+0x2ad>
    1481:	83 7d c8 00          	cmpl   $0x0,-0x38(%rbp)
    1485:	7c 1e                	jl     14a5 <readMemoryByte+0x2a5>
    1487:	48 63 4d d0          	movslq -0x30(%rbp),%rcx
    148b:	48 8d 05 9e 2c 02 00 	lea    0x22c9e(%rip),%rax        # 24130 <readMemoryByte.results>
    1492:	8b 04 88             	mov    (%rax,%rcx,4),%eax
    1495:	48 63 55 c8          	movslq -0x38(%rbp),%rdx
    1499:	48 8d 0d 90 2c 02 00 	lea    0x22c90(%rip),%rcx        # 24130 <readMemoryByte.results>
    14a0:	3b 04 91             	cmp    (%rcx,%rdx,4),%eax
    14a3:	7c 06                	jl     14ab <readMemoryByte+0x2ab>
    14a5:	8b 45 d0             	mov    -0x30(%rbp),%eax
    14a8:	89 45 c8             	mov    %eax,-0x38(%rbp)
    14ab:	eb 00                	jmp    14ad <readMemoryByte+0x2ad>
    14ad:	eb 00                	jmp    14af <readMemoryByte+0x2af>
    14af:	8b 45 d0             	mov    -0x30(%rbp),%eax
    14b2:	83 c0 01             	add    $0x1,%eax
    14b5:	89 45 d0             	mov    %eax,-0x30(%rbp)
    14b8:	eb 8c                	jmp    1446 <readMemoryByte+0x246>
    14ba:	48 63 4d cc          	movslq -0x34(%rbp),%rcx
    14be:	48 8d 05 6b 2c 02 00 	lea    0x22c6b(%rip),%rax        # 24130 <readMemoryByte.results>
    14c5:	8b 04 88             	mov    (%rax,%rcx,4),%eax
    14c8:	48 63 55 c8          	movslq -0x38(%rbp),%rdx
    14cc:	48 8d 0d 5d 2c 02 00 	lea    0x22c5d(%rip),%rcx        # 24130 <readMemoryByte.results>
    14d3:	8b 0c 91             	mov    (%rcx,%rdx,4),%ecx
    14d6:	d1 e1                	shl    %ecx
    14d8:	83 c1 05             	add    $0x5,%ecx
    14db:	39 c8                	cmp    %ecx,%eax
    14dd:	7d 22                	jge    1501 <readMemoryByte+0x301>
    14df:	48 63 4d cc          	movslq -0x34(%rbp),%rcx
    14e3:	48 8d 05 46 2c 02 00 	lea    0x22c46(%rip),%rax        # 24130 <readMemoryByte.results>
    14ea:	83 3c 88 02          	cmpl   $0x2,(%rax,%rcx,4)
    14ee:	75 13                	jne    1503 <readMemoryByte+0x303>
    14f0:	48 63 4d c8          	movslq -0x38(%rbp),%rcx
    14f4:	48 8d 05 35 2c 02 00 	lea    0x22c35(%rip),%rax        # 24130 <readMemoryByte.results>
    14fb:	83 3c 88 00          	cmpl   $0x0,(%rax,%rcx,4)
    14ff:	75 02                	jne    1503 <readMemoryByte+0x303>
    1501:	eb 10                	jmp    1513 <readMemoryByte+0x313>
    1503:	eb 00                	jmp    1505 <readMemoryByte+0x305>
    1505:	8b 45 d4             	mov    -0x2c(%rbp),%eax
    1508:	83 c0 ff             	add    $0xffffffff,%eax
    150b:	89 45 d4             	mov    %eax,-0x2c(%rbp)
    150e:	e9 3f fd ff ff       	jmp    1252 <readMemoryByte+0x52>
    1513:	8b 45 c0             	mov    -0x40(%rbp),%eax
    1516:	33 05 14 2c 02 00    	xor    0x22c14(%rip),%eax        # 24130 <readMemoryByte.results>
    151c:	89 05 0e 2c 02 00    	mov    %eax,0x22c0e(%rip)        # 24130 <readMemoryByte.results>
    1522:	8b 45 cc             	mov    -0x34(%rbp),%eax
    1525:	88 c1                	mov    %al,%cl
    1527:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
    152b:	88 08                	mov    %cl,(%rax)
    152d:	48 63 4d cc          	movslq -0x34(%rbp),%rcx
    1531:	48 8d 05 f8 2b 02 00 	lea    0x22bf8(%rip),%rax        # 24130 <readMemoryByte.results>
    1538:	8b 0c 88             	mov    (%rax,%rcx,4),%ecx
    153b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
    153f:	89 08                	mov    %ecx,(%rax)
    1541:	8b 45 c8             	mov    -0x38(%rbp),%eax
    1544:	88 c1                	mov    %al,%cl
    1546:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
    154a:	88 48 01             	mov    %cl,0x1(%rax)
    154d:	48 63 4d c8          	movslq -0x38(%rbp),%rcx
    1551:	48 8d 05 d8 2b 02 00 	lea    0x22bd8(%rip),%rax        # 24130 <readMemoryByte.results>
    1558:	8b 0c 88             	mov    (%rax,%rcx,4),%ecx
    155b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
    155f:	89 48 04             	mov    %ecx,0x4(%rax)
    1562:	48 81 c4 90 00 00 00 	add    $0x90,%rsp
    1569:	5d                   	pop    %rbp
    156a:	c3                   	ret    
    156b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000000001570 <main>:
    1570:	55                   	push   %rbp
    1571:	48 89 e5             	mov    %rsp,%rbp
    1574:	48 83 ec 50          	sub    $0x50,%rsp
    1578:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    157f:	89 7d f8             	mov    %edi,-0x8(%rbp)
    1582:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
    1586:	e8 d5 fa ff ff       	call   1060 <getchar@plt>
    158b:	88 45 ef             	mov    %al,-0x11(%rbp)
    158e:	0f be 45 ef          	movsbl -0x11(%rbp),%eax
    1592:	83 f8 72             	cmp    $0x72,%eax
    1595:	0f 85 ec 01 00 00    	jne    1787 <main+0x217>
    159b:	48 8b 35 5e 2b 02 00 	mov    0x22b5e(%rip),%rsi        # 24100 <secret>
    15a2:	48 8b 15 57 2b 02 00 	mov    0x22b57(%rip),%rdx        # 24100 <secret>
    15a9:	48 8d 3d 7d 0a 00 00 	lea    0xa7d(%rip),%rdi        # 202d <_IO_stdin_used+0x2d>
    15b0:	b0 00                	mov    $0x0,%al
    15b2:	e8 99 fa ff ff       	call   1050 <printf@plt>
    15b7:	48 8b 05 42 2b 02 00 	mov    0x22b42(%rip),%rax        # 24100 <secret>
    15be:	48 8d 0d 9b 2a 00 00 	lea    0x2a9b(%rip),%rcx        # 4060 <array1>
    15c5:	48 29 c8             	sub    %rcx,%rax
    15c8:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
    15cc:	48 8b 3d 2d 2b 02 00 	mov    0x22b2d(%rip),%rdi        # 24100 <secret>
    15d3:	e8 68 fa ff ff       	call   1040 <strlen@plt>
    15d8:	89 45 d4             	mov    %eax,-0x2c(%rbp)
    15db:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
    15e2:	00 
    15e3:	48 81 7d c8 00 00 02 	cmpq   $0x20000,-0x38(%rbp)
    15ea:	00 
    15eb:	73 1d                	jae    160a <main+0x9a>
    15ed:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
    15f1:	48 8d 05 08 2b 00 00 	lea    0x2b08(%rip),%rax        # 4100 <array2>
    15f8:	c6 04 08 01          	movb   $0x1,(%rax,%rcx,1)
    15fc:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
    1600:	48 83 c0 01          	add    $0x1,%rax
    1604:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    1608:	eb d9                	jmp    15e3 <main+0x73>
    160a:	83 7d f8 03          	cmpl   $0x3,-0x8(%rbp)
    160e:	75 5b                	jne    166b <main+0xfb>
    1610:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    1614:	48 8b 78 08          	mov    0x8(%rax),%rdi
    1618:	48 8d 55 e0          	lea    -0x20(%rbp),%rdx
    161c:	48 8d 35 2e 0a 00 00 	lea    0xa2e(%rip),%rsi        # 2051 <_IO_stdin_used+0x51>
    1623:	b0 00                	mov    $0x0,%al
    1625:	e8 46 fa ff ff       	call   1070 <__isoc99_sscanf@plt>
    162a:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
    162e:	48 8d 0d 2b 2a 00 00 	lea    0x2a2b(%rip),%rcx        # 4060 <array1>
    1635:	48 29 c8             	sub    %rcx,%rax
    1638:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
    163c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    1640:	48 8b 78 10          	mov    0x10(%rax),%rdi
    1644:	48 8d 35 09 0a 00 00 	lea    0xa09(%rip),%rsi        # 2054 <_IO_stdin_used+0x54>
    164b:	48 8d 55 d4          	lea    -0x2c(%rbp),%rdx
    164f:	b0 00                	mov    $0x0,%al
    1651:	e8 1a fa ff ff       	call   1070 <__isoc99_sscanf@plt>
    1656:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
    165a:	8b 55 d4             	mov    -0x2c(%rbp),%edx
    165d:	48 8d 3d f3 09 00 00 	lea    0x9f3(%rip),%rdi        # 2057 <_IO_stdin_used+0x57>
    1664:	b0 00                	mov    $0x0,%al
    1666:	e8 e5 f9 ff ff       	call   1050 <printf@plt>
    166b:	8b 75 d4             	mov    -0x2c(%rbp),%esi
    166e:	48 8d 3d 05 0a 00 00 	lea    0xa05(%rip),%rdi        # 207a <_IO_stdin_used+0x7a>
    1675:	b0 00                	mov    $0x0,%al
    1677:	e8 d4 f9 ff ff       	call   1050 <printf@plt>
    167c:	8b 45 d4             	mov    -0x2c(%rbp),%eax
    167f:	83 c0 ff             	add    $0xffffffff,%eax
    1682:	89 45 d4             	mov    %eax,-0x2c(%rbp)
    1685:	83 f8 00             	cmp    $0x0,%eax
    1688:	0f 8c f7 00 00 00    	jl     1785 <main+0x215>
    168e:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
    1692:	48 8d 3d f4 09 00 00 	lea    0x9f4(%rip),%rdi        # 208d <_IO_stdin_used+0x8d>
    1699:	b0 00                	mov    $0x0,%al
    169b:	e8 b0 f9 ff ff       	call   1050 <printf@plt>
    16a0:	48 8b 7d e0          	mov    -0x20(%rbp),%rdi
    16a4:	48 89 f8             	mov    %rdi,%rax
    16a7:	48 83 c0 01          	add    $0x1,%rax
    16ab:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
    16af:	48 8d 75 d2          	lea    -0x2e(%rbp),%rsi
    16b3:	48 8d 55 d8          	lea    -0x28(%rbp),%rdx
    16b7:	e8 44 fb ff ff       	call   1200 <readMemoryByte>
    16bc:	8b 4d d8             	mov    -0x28(%rbp),%ecx
    16bf:	8b 55 dc             	mov    -0x24(%rbp),%edx
    16c2:	d1 e2                	shl    %edx
    16c4:	48 8d 35 ef 09 00 00 	lea    0x9ef(%rip),%rsi        # 20ba <_IO_stdin_used+0xba>
    16cb:	48 8d 05 e0 09 00 00 	lea    0x9e0(%rip),%rax        # 20b2 <_IO_stdin_used+0xb2>
    16d2:	39 d1                	cmp    %edx,%ecx
    16d4:	48 0f 4d f0          	cmovge %rax,%rsi
    16d8:	48 8d 3d ce 09 00 00 	lea    0x9ce(%rip),%rdi        # 20ad <_IO_stdin_used+0xad>
    16df:	b0 00                	mov    $0x0,%al
    16e1:	e8 6a f9 ff ff       	call   1050 <printf@plt>
    16e6:	0f b6 45 d2          	movzbl -0x2e(%rbp),%eax
    16ea:	89 45 c4             	mov    %eax,-0x3c(%rbp)
    16ed:	0f b6 45 d2          	movzbl -0x2e(%rbp),%eax
    16f1:	83 f8 1f             	cmp    $0x1f,%eax
    16f4:	7e 12                	jle    1708 <main+0x198>
    16f6:	0f b6 45 d2          	movzbl -0x2e(%rbp),%eax
    16fa:	83 f8 7f             	cmp    $0x7f,%eax
    16fd:	7d 09                	jge    1708 <main+0x198>
    16ff:	0f b6 45 d2          	movzbl -0x2e(%rbp),%eax
    1703:	89 45 c0             	mov    %eax,-0x40(%rbp)
    1706:	eb 0a                	jmp    1712 <main+0x1a2>
    1708:	b8 3f 00 00 00       	mov    $0x3f,%eax
    170d:	89 45 c0             	mov    %eax,-0x40(%rbp)
    1710:	eb 00                	jmp    1712 <main+0x1a2>
    1712:	8b 75 c4             	mov    -0x3c(%rbp),%esi
    1715:	8b 55 c0             	mov    -0x40(%rbp),%edx
    1718:	8b 4d d8             	mov    -0x28(%rbp),%ecx
    171b:	48 8d 3d a0 09 00 00 	lea    0x9a0(%rip),%rdi        # 20c2 <_IO_stdin_used+0xc2>
    1722:	b0 00                	mov    $0x0,%al
    1724:	e8 27 f9 ff ff       	call   1050 <printf@plt>
    1729:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
    172d:	7e 43                	jle    1772 <main+0x202>
    172f:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
    1733:	89 45 bc             	mov    %eax,-0x44(%rbp)
    1736:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
    173a:	83 f8 1f             	cmp    $0x1f,%eax
    173d:	7e 12                	jle    1751 <main+0x1e1>
    173f:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
    1743:	83 f8 7f             	cmp    $0x7f,%eax
    1746:	7d 09                	jge    1751 <main+0x1e1>
    1748:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
    174c:	89 45 b8             	mov    %eax,-0x48(%rbp)
    174f:	eb 0a                	jmp    175b <main+0x1eb>
    1751:	b8 3f 00 00 00       	mov    $0x3f,%eax
    1756:	89 45 b8             	mov    %eax,-0x48(%rbp)
    1759:	eb 00                	jmp    175b <main+0x1eb>
    175b:	8b 75 bc             	mov    -0x44(%rbp),%esi
    175e:	8b 55 b8             	mov    -0x48(%rbp),%edx
    1761:	8b 4d dc             	mov    -0x24(%rbp),%ecx
    1764:	48 8d 3d 6d 09 00 00 	lea    0x96d(%rip),%rdi        # 20d8 <_IO_stdin_used+0xd8>
    176b:	b0 00                	mov    $0x0,%al
    176d:	e8 de f8 ff ff       	call   1050 <printf@plt>
    1772:	48 8d 3d 12 09 00 00 	lea    0x912(%rip),%rdi        # 208b <_IO_stdin_used+0x8b>
    1779:	b0 00                	mov    $0x0,%al
    177b:	e8 d0 f8 ff ff       	call   1050 <printf@plt>
    1780:	e9 f7 fe ff ff       	jmp    167c <main+0x10c>
    1785:	eb 41                	jmp    17c8 <main+0x258>
    1787:	0f be 45 ef          	movsbl -0x11(%rbp),%eax
    178b:	83 f8 0a             	cmp    $0xa,%eax
    178e:	75 05                	jne    1795 <main+0x225>
    1790:	e9 f1 fd ff ff       	jmp    1586 <main+0x16>
    1795:	0f be 45 ef          	movsbl -0x11(%rbp),%eax
    1799:	83 f8 69             	cmp    $0x69,%eax
    179c:	75 24                	jne    17c2 <main+0x252>
    179e:	b0 00                	mov    $0x0,%al
    17a0:	e8 8b f8 ff ff       	call   1030 <getpid@plt>
    17a5:	89 c2                	mov    %eax,%edx
    17a7:	48 8d 3d 4e 09 00 00 	lea    0x94e(%rip),%rdi        # 20fc <_IO_stdin_used+0xfc>
    17ae:	48 8d 35 cb f9 ff ff 	lea    -0x635(%rip),%rsi        # 1180 <check>
    17b5:	48 83 c6 21          	add    $0x21,%rsi
    17b9:	b0 00                	mov    $0x0,%al
    17bb:	e8 90 f8 ff ff       	call   1050 <printf@plt>
    17c0:	eb 02                	jmp    17c4 <main+0x254>
    17c2:	eb 09                	jmp    17cd <main+0x25d>
    17c4:	eb 00                	jmp    17c6 <main+0x256>
    17c6:	eb 00                	jmp    17c8 <main+0x258>
    17c8:	e9 b9 fd ff ff       	jmp    1586 <main+0x16>
    17cd:	31 c0                	xor    %eax,%eax
    17cf:	48 83 c4 50          	add    $0x50,%rsp
    17d3:	5d                   	pop    %rbp
    17d4:	c3                   	ret    

Disassembly of section .fini:

00000000000017d8 <_fini>:
    17d8:	f3 0f 1e fa          	endbr64 
    17dc:	48 83 ec 08          	sub    $0x8,%rsp
    17e0:	48 83 c4 08          	add    $0x8,%rsp
    17e4:	c3                   	ret    
