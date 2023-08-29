<%@ LANGUAGE="VBSCRIPT" %>
<%   
Option Explicit
'------------------------------------------------------
'------------------------------------------------------
' File Name: calendarpopup.asp
'
'   Propósito:
'   Apresentar uma janela para seleção de data.
'
'   Argumentos:
'   m = Mês a apresentar por default (não obrigatório)
'	y = Ano a apresentar por default (não obrigatório)
'   form = Nome do form da página chamadora (obrigatório)
'   field = nome do campo texto do form da página chamadora (obrigatório)
'
'   Autor:  Marcelo Camargo
'           Advanced Solutions S/C Ltda
'           http://www.AdvancedSolutions.com.br
'           EMail: Camargo@AdvancedSolutions.com.br
'
'   Criado em: 03/03/2001
'
'------------------------------------------------------
'------------------------------------------------------

' -- Declaração de variáveis de escopo de módulo
Dim intM 		' Mês corrente
Dim intY		' Ano corrente
Dim intFDay		' 1o dia do mês
Dim intNoDays	' Número de dias no mês
Dim intMPrev	' Mês anterior
Dim intYPrev	' Ano anterior
Dim intMNext	' Próximo mês
Dim intYNext	' Próximo Ano
Dim varDate     ' Temporária para armazenar data

' -- Coloque aqui o formato de data desejado
Const DATE_FORMAT = "ddmmyyyy"  
' -- Coloque aqui o separador de data desejado
Const DATE_SEPARATOR = "/"      
'------------------------------------------------------
'------------------------------------------------------
' Execução do código principal desta página
'------------------------------------------------------
'------------------------------------------------------
MainFunc
'------------------------------------------------------
'------------------------------------------------------
Sub MainFunc
	' -- Checa o mês e ano no qual o calendário deve ser aberto
	' ---------------------------------------------------------
	' -- Mês em que deve ser apresentado o calendário
	intM = Request("m")
	' -- se branco, usa mês corrente
	If intM = ""  Then
	   intM = Month(Date())
	End If
	intY = Request("y")
	' -- se branco, usa ano corrente
	If intY = "" Then
	   intY = Year(Date())
	End If
	
	' -- Obtém informações necessárias para a montagem do calendário
	' --------------------------------------------------------------
	' -- Converte data para formato independente de configuração.
	' -- Dessa forma pode-se ter qualquer config de data no servidor web.
	varDate = dateserial(intY, intM, 1)
	intFDay = WeekDay(varDate)
	intNoDays = DateDiff("d", varDate, DateAdd("m", 1, varDate)) 
	intMPrev = Month(DateAdd("m",-1,varDate))
	intYPrev = Year(DateAdd("m",-1,varDate))
	intMNext = Month(DateAdd("m",1,varDate))
	intYNext = Year(DateAdd("m",1,varDate))

	' -- Monta a página a apresentar ao usuário
	' -----------------------------------------
	EscreveHeaderPagina
	EscreveTabelaNomeMes
	EscreveInicioTabelaCalendario
	EscreveLinhaTituloSemana
	EscreveCalendario ' Código que escreve o HTML do corpo do calendário
	EscreveFimTabelaCalendario
	EscreveTrailerPagina
	
	' -- Fim do processamento
	Response.End	
End Sub

'------------------------------------------------------
'------------------------------------------------------
' A seguir todas as rotinas utilizadas pelo corpo
' do código principal MainFunc().
'------------------------------------------------------
'------------------------------------------------------

Sub EscreveHeaderPagina()	
%>
<HTML>
<HEAD>
<TITLE>Selecione a Data&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TITLE>
<!--link REV="made" href="mailto:Camargo@AdvancedSolutions.com.br">
<meta NAME="keywords" CONTENT="advanced solutions microsoft asp internet desenvolvimento sistemas computação computador">
<meta NAME="description" CONTENT="Trabalhamos com desenvolvimento de sistemas para Internet e corporativos em várias plataformas e linguagens. Visite nosso site em www.as-business.com.br">
<meta NAME="ROBOTS" CONTENT="ALL">
<meta NAME="DC.Title" CONTENT="Advanced Solutions - Internet and Corporate Systems">
<meta NAME="DC.Creator" CONTENT="Marcelo Camargo - Patrícia Maura Angelini">
<meta NAME="DC.Subject" CONTENT="Desenvolvimento de sistemas em ASP, C++, javascript, Visual Basic, Oracle, SQL Server, MS Access, entre outros.">
<meta NAME="DC.Description" CONTENT="Trabalhamos com desenvolvimento de sistemas para Internet e corporativos em várias plataformas e linguagens.">
<meta NAME="DC.Publisher" CONTENT="Marcelo Camargo"-->
<STYLE>
<!-- 
	body, td {
		font-family: Tahoma, Verdana, Arial, Helvetica, Sans Serif;
		font-size: 8pt;
	}
// -->
</STYLE>
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
<!--
function GetDateFmt() {return '<%=DATE_FORMAT%>';}
function GetDateSep() {return '<%=DATE_SEPARATOR%>';}
function FormatDate(d,m,y){
  var ds=GetDateSep();
  var fmt=GetDateFmt();
  var aux;
  // -- Coloca zeros a esquerda se necessário no dia e Mês
  aux = new String(d); if ( aux.length == 1 ) d = '0'+d;
  aux = new String(m); if ( aux.length == 1 ) m = '0'+m;
  if(fmt=="mmddyyyy") return m+ds+d+ds+y;
  else if(fmt=="ddmmyyyy") return d+ds+m+ds+y;
  else /*if(fmt=="yyyymmdd")*/ return y+ds+m+ds+d;
}
function SetDateValue(d) {
	opener.document.<%=Request("form")%>.<%=Request("field")%>.value = FormatDate(d,<%=intM%>,<%=intY%>);
	// -- Marca flag de abertura de página de calendário com fechada
	opener.newwindow = null;
	opener.focus();
	self.close();
}
function SetTodayValue() {
	opener.document.<%=Request("form")%>.<%=Request("field")%>.value = FormatDate(<%=Day(Date)%>,<%=Month(Date)%>,<%=Year(Date)%>);
	// -- Marca flag de abertura de página de calendário com fechada
	opener.newwindow = null;
	opener.focus();
	self.close();
}
//-->
</SCRIPT>	
</HEAD>

<BODY BGCOLOR="#FFFFFF">
<DIV ALIGN="CENTER">
<%
End Sub

'------------------------------------------------------
'------------------------------------------------------
Sub EscreveTabelaNomeMes()
%>	
<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0" WIDTH="200" STYLE="border : 1px solid Black;">
<TR BGCOLOR="#CCCCCC"><TD WIDTH="12" ALIGN="CENTER" VALIGN="TOP">
<A HREF="<%=Request.ServerVariables("SCRIPT_NAME")%>?form=<%=Request("form")%>&field=<%=Request("field")%>&m=<%=intMPrev%>&y=<%= intYPrev %>">
<IMG SRC="calmLeft.gif" WIDTH="8" HEIGHT="12" ALT="Mês Anterior" BORDER="0"></A></TD>
<TD WIDTH="176" ALIGN="CENTER" VALIGN="TOP"><STRONG>
<%=GetMonthName(intM) & " de " & intY%></STRONG></TD>
<TD WIDTH="12" ALIGN="CENTER" VALIGN="TOP">
<A HREF="<%=Request.ServerVariables("SCRIPT_NAME")%>?form=<%=Request("form")%>&field=<%=Request("field")%>&m=<%=intMNext%>&y=<%= intYNext%>">
<IMG SRC="calmRight.gif" WIDTH="8" HEIGHT="12" ALT="Próximo Mês" BORDER="0"></A></TD>
</TR>
</TABLE>
<%
End Sub

'------------------------------------------------------
'------------------------------------------------------
Sub EscreveInicioTabelaCalendario()
%>
<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0" WIDTH="200" STYLE="border: 1px solid black;">
<%
End Sub

'------------------------------------------------------
'------------------------------------------------------
Sub EscreveLinhaTituloSemana()
%>
<TR>
	<TD>&nbsp;</TD>
	<TD WIDTH="20" ALIGN="CENTER" VALIGN="TOP">D</TD>
	<TD WIDTH="20" ALIGN="CENTER" VALIGN="TOP">S</TD>
	<TD WIDTH="20" ALIGN="CENTER" VALIGN="TOP">T</TD>
	<TD WIDTH="20" ALIGN="CENTER" VALIGN="TOP">Q</TD>
	<TD WIDTH="20" ALIGN="CENTER" VALIGN="TOP">Q</TD>
	<TD WIDTH="20" ALIGN="CENTER" VALIGN="TOP">S</TD>
	<TD WIDTH="20" ALIGN="CENTER" VALIGN="TOP">S</TD>
	<TD>&nbsp;</TD>
</TR>
<TR>
	<TD>&nbsp;</TD>
	<TD COLSPAN="7"><HR SIZE="1" COLOR="#808080" NOSHADE></TD>
	<TD>&nbsp;</TD>
</TR>
<%
End Sub

'------------------------------------------------------
'------------------------------------------------------
Sub EscreveFimTabelaCalendario()
%>
<TR>
	<TD>&nbsp;</A></TD>
	<TD COLSPAN="7"><HR SIZE="1" COLOR="#808080" NOSHADE></A></TD>
	<TD>&nbsp;</A></TD>
</TR>
<TR>
	<TD>&nbsp;</A></TD>
	<TD COLSPAN="7" ALIGN="CENTER" VALIGN="TOP">
	<FORM>
		<INPUT TYPE="BUTTON" NAME="B" VALUE="Hoje!" 
		STYLE="font-family: Tahoma; font-size: 8pt; width: 48px; height: 20px;"
		ONCLICK="SetTodayValue()">
	</FORM></TD>
	<TD>&nbsp;</A></TD>
</TR>
</TABLE>
<%
End Sub

'------------------------------------------------------
'------------------------------------------------------
Sub EscreveTrailerPagina()
%>
</DIV>
</BODY>
</HTML>
<%
End Sub

'------------------------------------------------------
'------------------------------------------------------
Sub EscreveCalendario()
	Dim i
	' -- Linha de início
	Response.Write "<TR>" & vbCrLf 
	' -- Coluna em branco da esquerda
	Response.Write "<TD>&nbsp;</TD>" & vbCrLf
	' -- Passa por todos possíveis dias disponíveis no cal impresso
	For i = 1 to 42
		' -- se estiver antes do início do mês
		If i < intFDay Then
			' -- escreve um branco
			WriteInActiveCalDay "&nbsp;"
		' -- se estiver depois do fim do mês
		ElseIf i > intNoDays + intFDay - 1 Then
			' -- escreve um branco
			WriteInActiveCalDay "&nbsp;"
		Else
			' -- escreve o dia
			WriteActiveCalDay (i- intFDay +1)
		End If
		' -- precisa mudar de linha?
		if i Mod 7 = 0 Then
			' -- estamos no fim da semana
			Response.Write "<TD>&nbsp;</TD>" & vbCrLf 
			' -- fim da linha
			Response.Write "</TR>" & vbCrLf
			' -- precisamos de outra linha?
			If i <= intNoDays + intFDay - 1  Then
				Response.Write "<TR>" & vbCrLf 
				Response.Write "<TD>&nbsp;</TD>" & vbCrLf
			Else
				' -- excedeu número de dias, sai!
				Exit For
			End if
		End if	
	Next
	' -- Preenche com brancos os dias vazios da última semana
	if i Mod 7 <> 0 Then
		Do While i Mod 7 > 0
			WriteInActiveCalDay "&nbsp;"
			i = i+1
		Loop
		Response.Write "<TD>&nbsp;</TD>" & vbCrLf 
		Response.Write "</TR>" & vbCrLf
	End if		
End Sub

'------------------------------------------------------
'------------------------------------------------------
Sub WriteInActiveCalDay(byval sLabel)
	Response.Write 	"<TD WIDTH=""20"" ALIGN=""CENTER"" VALIGN=""TOP"">" & sLabel & "</TD>" & vbCrLf
End Sub

'------------------------------------------------------
'------------------------------------------------------
Sub WriteActiveCalDay(byval sLabel)
	Response.Write 	"<TD WIDTH=""20"" ALIGN=""CENTER"" VALIGN=""TOP""><A HREF=""javascript:SetDateValue(" & Cint(sLabel) & ");"">" & sLabel & "</A></TD>" & vbCrLf
End Sub

'------------------------------------------------------
'------------------------------------------------------
Function GetMonthName(intMonth)
	select case (intMonth)
	case 1
		GetMonthName = "Janeiro"
		exit function
	case 2
		GetMonthName = "Fevereiro"
		exit function
	case 3
		GetMonthName = "Março"
		exit function
	case 4
		GetMonthName = "Abril"
		exit function
	case 5
		GetMonthName = "Maio"
		exit function
	case 6
		GetMonthName = "Junho"
		exit function
	case 7
		GetMonthName = "Julho"
		exit function
	case 8
		GetMonthName = "Agosto"
		exit function
	case 9
		GetMonthName = "Setembro"
		exit function
	case 10
		GetMonthName = "Outubro"
		exit function
	case 11
		GetMonthName = "Novembro"
		exit function
	case 12
		GetMonthName = "Dezembro"
		exit function
	End Select
End Function
'------------------------------------------------------
' -- Fim do Script.
'------------------------------------------------------
%>