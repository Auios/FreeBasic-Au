' version 20-10-2016
' FIPS PUB 180-4
' compile with: fbc -s console
 
Function SHA_256(test_str As String) As String
 
  #Macro Ch (x, y, z)
    (((x) And (y)) Xor ((Not (x)) And z))
  #EndMacro
 
  #Macro Maj (x, y, z)
    (((x) And (y)) Xor ((x) And (z)) Xor ((y) And (z)))
  #EndMacro
 
  #Macro sigma0 (x)
    (((x) Shr 2 Or (x) Shl 30) Xor ((x) Shr 13 Or (x) Shl 19) Xor ((x) Shr 22 Or (x) Shl 10))
  #EndMacro
 
  #Macro sigma1 (x)
    (((x) Shr 6 Or (x) Shl 26) Xor ((x) Shr 11 Or (x) Shl 21) Xor ((x) Shr 25 Or (x) Shl 7))
  #EndMacro
 
  #Macro sigma2 (x)
    (((x) Shr 7 Or (x) Shl 25) Xor ((x) Shr 18 Or (x) Shl 14) Xor ((x) Shr 3))
  #EndMacro
 
  #Macro sigma3 (x)
    (((x) Shr 17 Or (x) Shl 15) Xor ((x) Shr 19 Or (x) Shl 13) Xor ((x) Shr 10))
  #EndMacro
 
  Dim As String message = test_str   ' strings are passed as ByRef's
 
  Dim As Long i, j
  Dim As UByte Ptr ww1
  Dim As UInteger<32> Ptr ww4
 
  Dim As ULongInt l = Len(message)
  ' set the first bit after the message to 1
  message = message + Chr(1 Shl 7)
  ' add one char to the length
  Dim As ULong padding = 64 - ((l +1) Mod (512 \ 8)) ' 512 \ 8 = 64 char.
 
  ' check if we have enough room for inserting the length
  If padding < 8 Then padding = padding + 64
 
  message = message + String(padding, Chr(0))   ' adjust length
  Dim As ULong l1 = Len(message)                ' new length
 
  l = l * 8    ' orignal length in bits
  ' create ubyte ptr to point to l ( = length in bits)
  Dim As UByte Ptr ub_ptr = Cast(UByte Ptr, @l)
 
  For i = 0 To 7  'copy length of message to the last 8 bytes
    message[l1 -1 - i] = ub_ptr[i]
  Next
 
  'table of constants
  Dim As UInteger<32> K(0 To ...) = _
  { &H428a2f98, &H71374491, &Hb5c0fbcf, &He9b5dba5, &H3956c25b, &H59f111f1, _
    &H923f82a4, &Hab1c5ed5, &Hd807aa98, &H12835b01, &H243185be, &H550c7dc3, _
    &H72be5d74, &H80deb1fe, &H9bdc06a7, &Hc19bf174, &He49b69c1, &Hefbe4786, _
    &H0fc19dc6, &H240ca1cc, &H2de92c6f, &H4a7484aa, &H5cb0a9dc, &H76f988da, _
    &H983e5152, &Ha831c66d, &Hb00327c8, &Hbf597fc7, &Hc6e00bf3, &Hd5a79147, _
    &H06ca6351, &H14292967, &H27b70a85, &H2e1b2138, &H4d2c6dfc, &H53380d13, _
    &H650a7354, &H766a0abb, &H81c2c92e, &H92722c85, &Ha2bfe8a1, &Ha81a664b, _
    &Hc24b8b70, &Hc76c51a3, &Hd192e819, &Hd6990624, &Hf40e3585, &H106aa070, _
    &H19a4c116, &H1e376c08, &H2748774c, &H34b0bcb5, &H391c0cb3, &H4ed8aa4a, _
    &H5b9cca4f, &H682e6ff3, &H748f82ee, &H78a5636f, &H84c87814, &H8cc70208, _
    &H90befffa, &Ha4506ceb, &Hbef9a3f7, &Hc67178f2 }
 
  Dim As UInteger<32> h0 = &H6a09e667
  Dim As UInteger<32> h1 = &Hbb67ae85
  Dim As UInteger<32> h2 = &H3c6ef372
  Dim As UInteger<32> h3 = &Ha54ff53a
  Dim As UInteger<32> h4 = &H510e527f
  Dim As UInteger<32> h5 = &H9b05688c
  Dim As UInteger<32> h6 = &H1f83d9ab
  Dim As UInteger<32> h7 = &H5be0cd19
  Dim As UInteger<32> a, b, c, d, e, f, g, h
  Dim As UInteger<32> t1, t2, w(0 To 63)
 
 
  For j = 0 To (l1 -1) \ 64 ' split into block of 64 bytes
    ww1 = Cast(UByte Ptr, @message[j * 64])
    ww4 = Cast(UInteger<32> Ptr, @message[j * 64])
 
    For i = 0 To 60 Step 4  'little endian -> big endian
      Swap ww1[i   ], ww1[i +3]
      Swap ww1[i +1], ww1[i +2]
    Next
 
    For i = 0 To 15    ' copy the 16 32bit block into the array
      W(i) = ww4[i]
    Next
 
    For i = 16 To 63   ' fill the rest of the array
      w(i) = sigma3(W(i -2)) + W(i -7) + sigma2(W(i -15)) + W(i -16)
    Next
 
    a = h0 : b = h1 : c = h2 : d = h3 : e = h4 : f = h5 : g = h6 : h = h7
 
    For i = 0 To 63
      t1 = h + sigma1(e) + Ch(e, f, g) + K(i) + W(i)
      t2 = sigma0(a) + Maj(a, b, c)
      h = g : g = f : f = e
      e = d + t1
      d = c : c = b : b = a
      a = t1 + t2
    Next
 
    h0 += a : h1 += b : h2 += c : h3 += d
    h4 += e : h5 += f : h6 += g : h7 += h
 
  Next j
 
  Dim As String answer  = Hex(h0, 8) + Hex(h1, 8) + Hex(h2, 8) + Hex(h3, 8)
                answer += Hex(h4, 8) + Hex(h5, 8) + Hex(h6, 8) + Hex(h7, 8)
 
  Return LCase(answer)
 
End Function