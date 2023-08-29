<cfprocessingdirective pageEncoding ="utf-8"/>
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
   <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>        

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena
	FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
	WHERE Usu_DR = '#form.frmse#'
</cfquery> 

<!---  --->
<cfif isDefined("Form.sacao") and #form.sacao# is 'inc'>
	<cfoutput>
		<cfquery name="rsExiste" datasource="#dsn_inspecao#">		
			SELECT PPU_Parecer
			FROM PacinPermutaUnidade
			WHERE PPU_Ano='#Form.frmano#' and PPU_DEUnidade='#Form.frmunidde#' and PPU_PARAUnidade='#Form.frmunidpara#'
		</cfquery> 
		<cfif rsExiste.recordcount gt 0>
			<cfset parecer = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>Solicitar Permuta de Avaliação no PACIN' & CHR(13) & CHR(13) & 'À(O) CS/DIGOE/SUGOV/DCINT/GCOP' & CHR(13) & CHR(13) & 'Solicitamos ao GESTORMASTER a realização de permuta de Avaliação no PACIN ' & #Form.frmano# & ' entre as unidades de: ' & #frmunidde# & ' - ' & #frmuniddedesc# & ' para: ' & #frmunidpara# & ' - ' & #frmunidparadesc# & ' junto ao sistema SNCI pela motivação ' & #form.frmmotivo#  & CHR(13) & ' Detalhes da solicitação(Outros): ' & CHR(13) & #form.frmdescoutros# & CHR(13) & CHR(13) &  'Responsável: ' & #CGI.REMOTE_USER# & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------' & CHR(13) & CHR(13) & #rsExiste.PPU_Parecer#>		  
			<cfquery datasource="#dsn_inspecao#" name="qVerifica">
			 update PacinPermutaUnidade set PPU_Motivo='#Form.frmmotivo#'
			 ,PPU_Parecer='#parecer#'
			 ,PPU_Status='S'
			 ,PPU_dtultatu=CONVERT(char, GETDATE(), 120)
			 ,PPU_username='#CGI.REMOTE_USER#'		
			 WHERE PPU_Ano='#Form.frmano#' and PPU_DEUnidade='#Form.frmunidde#' and PPU_PARAUnidade='#Form.frmunidpara#'
			</cfquery>	
		<cfelse>				
			<cfset parecer = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>Solicitar Permuta de Avaliação no PACIN' & CHR(13) & CHR(13) & 'À(O) CS/DIGOE/SUGOV/DCINT/GCOP' & CHR(13) & CHR(13) & 'Solicitamos ao GESTORMASTER a realização de permuta de Avaliação no PACIN ' & #Form.frmano# & ' entre as unidades de: ' & #frmunidde# & ' - ' & #frmuniddedesc# & ' para: ' & #frmunidpara# & ' - ' & #frmunidparadesc# & ' junto ao sistema SNCI pela motivação ' & #form.frmmotivo#  & CHR(13) & #form.frmdescoutros# & CHR(13) & CHR(13) &  'Responsável: ' & #CGI.REMOTE_USER# & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>		
				
			<cfquery datasource="#dsn_inspecao#" name="qVerifica">
				 INSERT INTO PacinPermutaUnidade (PPU_Ano,PPU_DEUnidade,PPU_PARAUnidade,PPU_Motivo,PPU_Parecer,PPU_Status,PPU_dtultatu,PPU_username)		
				 VALUES ('#Form.frmano#'
				 ,'#Form.frmunidde#'
				 ,'#Form.frmunidpara#'
				 ,'#Form.frmmotivo#'
				 ,'#parecer#'
				 ,'S'
				 ,CONVERT(char, GETDATE(), 120)
				 ,'#CGI.REMOTE_USER#')
			</cfquery>
		</cfif>		
		
		<!---  --->
			<cfset corpo = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & CHR(13) & CHR(13) & 'Solicitação de Permuta de Avaliação' & CHR(13) & CHR(13) & 'À(O) CS/DIGOE/SUGOV/DCINT/GCOP' & CHR(13) & CHR(13) & 'Solicitamos ao GESTORMASTER a realização de permuta de Avaliação no exercício ' & #Form.frmano# & ' entre as unidades de: ' & #frmunidde# & ' - ' & #frmuniddedesc# & ' para: ' & #frmunidpara# & ' - ' & #frmunidparadesc# & ' junto ao sistema SNCI pela motivação ' & #form.frmmotivo#  & CHR(13) & #form.frmdescoutros# & CHR(13) & CHR(13) &  'Responsável: ' & #CGI.REMOTE_USER#>
			<cfmail from="SNCI@correios.com.br" to="adrianosoares@correios.com.br;teciogomes@correios.com.br;gilvanm@correios.com.br" subject="Solicitação por Permuta de Avaliação" type="HTML">
				 Mensagem automática. Não precisa responder!<br><br>
				<strong>
				  #corpo#<br><br>
				  &nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
				</strong>
			</cfmail>		
		<!--- Excluir e anexar arquivo  --->
			<cfif form.arquivo neq ''>
			<!--- Excluir arquivo pdf --->
				<cfquery name="rsCaminho" datasource="#dsn_inspecao#">
					select PPU_Anexo 
					from PacinPermutaUnidade 
					WHERE PPU_DEUnidade='#form.frmunidde#' and 
					PPU_PARAUnidade='#form.frmunidpara#' and 
					PPU_Ano='#form.frmano#'
				</cfquery>
				<!--- Exluindo arquivo do diretorio de Anexos --->
				<cfif trim(rsCaminho.PPU_Anexo) neq ''>
					<cffile action="delete" file="#diretorio_anexos##rsCaminho.PPU_Anexo#">
				</cfif>
			<!--- fim Excluir arquivo pdf --->
			<!--- Incluir arquivo pdf --->
				<cffile action="upload" filefield="arquivo" destination="#diretorio_anexos#" nameconflict="overwrite" accept="application/pdf">
				<cfset data = DateFormat(now(),'YYYYMMDD') & '_' & TimeFormat(Now(),'HH') & 'h' & TimeFormat(Now(),'MM') & 'm' & TimeFormat(Now(),'SS') & 's'>
				<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>
				<cfset destino = Form.frmano & Form.frmunidde & Form.frmunidpara & '_' & data & '_' & right(CGI.REMOTE_USER,8) & '.pdf'>
<!--- 			<cfoutput>
			origem:#origem# <br> destino:#destino#
			</cfoutput>
			<cfset gil = gil> --->
				<cfif FileExists(origem)>
					<cffile action="rename" source="#origem#" destination="#destino#">
					<cfquery datasource="#dsn_inspecao#">
					UPDATE PacinPermutaUnidade SET PPU_Anexo = '#destino#', PPU_dtultatu = convert(char, getdate(), 102), PPU_username = '#CGI.REMOTE_USER#'
					WHERE PPU_DEUnidade='#form.frmunidde#' and PPU_PARAUnidade='#form.frmunidpara#' and PPU_Ano='#form.frmano#'
					</cfquery>
			   </cfif>
			</cfif>		
		<!--- fim Excluir e anexar arquivo  --->
	</cfoutput> 
    <cflocation url="Pacin_Permuta_Avaliacao.cfm?frmse=#form.frmse#&frmano=#form.frmano#&frmtipounid=#form.frmtipounid#">
</cfif>
<!---  --->
		
	<cfquery name="rsUnidde" datasource="#dsn_inspecao#">
		SELECT TUN_Codigo, TUN_Descricao, Und_Codigo, Und_Descricao,Und_Ano_Horas_Avaliar, Und_Ano_Pontos_Avaliar
		FROM Tipo_Unidades 
		INNER JOIN Unidades ON TUN_Codigo = Und_TipoUnidade
		WHERE Und_Codigo = '#form.frmunidde#' 
	</cfquery>
	<cfquery name="rsUnidpara" datasource="#dsn_inspecao#">
		SELECT Und_Codigo, Und_Descricao, Und_Ano_Horas_Avaliar, Und_Ano_Pontos_Avaliar
		FROM Unidades 
		WHERE Und_Codigo= '#form.frmunidpara#'
	</cfquery>	

	

	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>Sistema Nacional de Controle Interno</title>
	<link href="../../estilo.css" rel="stylesheet" type="text/css">
	<link href="css.css" rel="stylesheet" type="text/css">

<script language="JavaScript" src="../../mm_menu.js"></script>
<script type="text/javascript">
function validaForm() {
	if (document.form1.sacao.value == 'inc'){
	    var sfrmmotivo = document.form1.frmmotivo.value;
		
		if (sfrmmotivo == 'OUTROS' || sfrmmotivo == 'INVIABILIDADE') 
		{
			var sfrmdescoutros = document.form1.frmdescoutros.value;
			if (sfrmdescoutros == ''){
			   alert('Caro Usuário, falta especificar a motivação desta solicitação!');
			   return false;
			   }
		}
//--------------------------------
		if (document.form1.arquivo.value == '')
			{
//			  alert('Você deve informar o caminho do arquivo a ser anexado!');
//			  document.form1.arquivo.focus();
//			  return false;
			  var auxcam = '\n\nFoi identificado a falta de um anexo nesta solicitação de permuta!\n\nDeseja Continuar mesmo assim?';
			  if (confirm ('            Atenção!' + auxcam))
				{
				//	 return true;
				}
				else
				   {
 					 document.form1.arquivo.focus();
					 document.form1.sacao.value='';
					 return false;
				  }
		}
//--------------------------------
   		var auxcam = '\n\nConfirma ao envio de Solicitação de Permuta no PACIN?';
		if (confirm ('            Atenção!' + auxcam))
		{
			 document.form1.frmdescoutros.disabled = false;
			 return true;
		}
		else
		   {
			 if (sfrmmotivo != 'OUTROS') {document.form1.frmdescoutros.disabled = true};
			 document.form1.sacao.value='';
			 return false;
		  }
		}
}
</script>
	<style type="text/css">
<!--
.style1 {color: #FFFFFF}
-->
    </style>
	</head>

<body>


<cfinclude template="cabecalho.cfm">
	    <span class="exibir"><strong>
	    </strong></span>
        <table width="64%" border="0" align="center">
          <tr valign="baseline">
            <td colspan="6" class="exibir">&nbsp;</td>
          </tr>
          <tr valign="baseline">
            <td colspan="6" class="exibir"><div align="center"><span class="titulo2"><strong class="titulo1">SOLICITAR PERMUTA POR </strong> <span class="titulo1">AVALIA&Ccedil;&Atilde;O DE UNIDADE NO PACIN</span></span></div></td>
          </tr>
          <tr valign="baseline">
            <td colspan="6">&nbsp;</td>
          </tr>
	  
          <cfoutput>
            <tr valign="baseline">
              <td width="14%"><div align="right"><span class="titulos">Superintendência:</span></div></td>
              <td width="17%"><div align="left">
                <select name="dr" id="dr" class="form" disabled>
                  <option selected="selected" value="#qAcesso.Usu_DR#">#qAcesso.Dir_Sigla#</option>
                </select>
              </div></td>
              <td width="21%"><div align="right"><span class="titulos">Tipo de Unidade  :</span></div></td>
              <td width="25%"><div align="left">
                <select name="frmtipounid" id="frmtipounid" class="form" disabled>
                 <cfif form.frmtipounid eq 'Todas'>
				 	<option value="Todas" selected="selected">Todas</option>
				 <cfelse>
					<option selected="selected" value="#rsUnidde.TUN_Codigo#">#rsUnidde.TUN_Descricao#</option>
				 </cfif>
                </select>
              </div></td>
              <td width="6%"><div align="right"><span class="titulos">Exercício:</span></div></td>
              <td width="17%"><div align="left">
                <select name="frmano" id="frmano" class="form"" disabled>
                  <option value="#frmano#">#frmano#</option>
                </select>
              </div></td>
            </tr>
          </cfoutput>
</table>

	    <table width="64%" border="0" align="center">
          <form action="Pacin_Permuta_Avaliacao1.cfm" method="post" target="_parent" name="form1" onSubmit="return validaForm()" enctype="multipart/form-data">
            <tr bgcolor="f7f7f7">
              <td colspan="8" align="center" bgcolor="f7f7f7" class="titulo1">&nbsp;</td>
            </tr>
            <tr bgcolor="f7f7f7">
              <td colspan="8" align="center" bgcolor="#CCCCCC" class="titulo1">Unidade(s) SELECIONADAS PARA PERMUTAREM NO PACIN de <cfoutput>#form.frmano#</cfoutput></td>
            </tr>

                  <tr bgcolor="#CCCCCC" class="titulos">
                    <td width="9%">&nbsp;</td>
                    <td width="36%">Cód. Unidade</td>
                    <td width="29%">Nome da Unidade </td>
                    <td width="8%"><div align="center">Horas de avaliação </div></td>
                    <td width="18%">Ranking de Pontuação de Avaliação </td>
                  </tr>
  

                      <tr class="titulos" bgcolor="f7f7f7">
                        <td bgcolor="#FF3300"><span class="style1">DE &nbsp;&nbsp; &nbsp;&nbsp;:</span></td>
                        <td><cfoutput>#rsUnidde.Und_Codigo#</cfoutput></td>
                        <td><cfoutput>#rsUnidde.Und_Descricao#</cfoutput></td>
						<cfset horas = rsUnidde.Und_Ano_Horas_Avaliar>
                        <td><div align="center"><cfoutput>#horas#</cfoutput></div></td>
						<cfset pontos = numberFormat(rsUnidde.Und_Ano_Pontos_Avaliar,99.00)>
                        <td><div align="center"><cfoutput>#pontos#</cfoutput></div></td>
            </tr>
					  <tr class="titulos" bgcolor="#EEEEEE">
                        <td bgcolor="#33CCFF">PARA:</td>
                        <td><cfoutput>#rsUnidpara.Und_Codigo#</cfoutput></td>
                        <td bgcolor="#EEEEEE"><cfoutput>#rsUnidpara.Und_Descricao#</cfoutput></td>
						<cfset horas = rsUnidpara.Und_Ano_Horas_Avaliar>
                        <td bgcolor="#EEEEEE"><div align="center"><cfoutput>#horas#</cfoutput></div></td>
						<cfset pontos = numberFormat(rsUnidpara.Und_Ano_Pontos_Avaliar,99.00)>
                        <td bgcolor="#EEEEEE"><div align="center"><cfoutput>#pontos#</cfoutput></div></td>
		    </tr>
                      <tr>
                        <td colspan="8">&nbsp;</td>
                      </tr>
                      
            <tr bgcolor="#EEEEEE" class="titulos">
              <td colspan="8"><div align="center">MOTIVO DA SOLICITAÇÃO</div></td>
            </tr>
			<tr class="exibir">
			<td colspan="8"><div align="center">
			  <table width="100%" border="0">

			    <tr bgcolor="#EEEEEE" class="form">
			      <td width="33%">
		          <div align="center"><strong>
                  <input name="rdbmotivo" type="radio" value="F" onClick="document.form1.frmdescoutros.disabled = true;document.form1.confirma.disabled=false;document.form1.frmmotivo.value='FECHAMENTO DE UNIDADE'">
                  FECHAMENTO DE UNIDADE</strong></div></td>
			  <td width="39%">
			    <div align="center"><strong><input name="rdbmotivo" type="radio" value="I" onClick="document.form1.frmdescoutros.disabled = false;document.form1.confirma.disabled=false;;document.form1.frmmotivo.value='INVIABILIDADE'">
		        INVIABILIDADE</strong></div></td>
			  <td width="28%"><div align="center"><strong>
		          <input name="rdbmotivo" type="radio" value="O" onClick="document.form1.frmdescoutros.disabled = false;document.form1.confirma.disabled=false;document.form1.confirma.disabled=false;document.form1.frmmotivo.value='OUTROS'">
		          OUTROS</strong></div></td>
			  </tr>
			    <tr bgcolor="#EEEEEE" class="form">
			      <td colspan="3"><hr></td>
		        </tr>
			    <tr bgcolor="#EEEEEE" class="titulos">
			      <td colspan="3"><div align="center">Especificar o motivo da solicitação </div></td>
	            </tr>
			    <tr bgcolor="#EEEEEE" class="form">
			      <td colspan="3"><label>
			        <div align="center">
			          <textarea name="frmdescoutros" cols="120" rows="5" disabled></textarea>
		            </div>
			      </label></td>
	            </tr>							  
		      </table>
			  </div></td>
			</tr>
<!--- Visualizacao de anexos --->

            <tr>
              <td colspan="9">
			  <table width="100%" border="0">
                <tr>
                  <td width="22%"><div align="left"><strong class="exibir">Caminho do  arquivo (PDF) :</strong></div></td>
                  <td colspan="3"><div align="left"><span class="exibir"><input name="arquivo" class="botao" type="file" size="100"></span></div>				  </td>
                </tr>
        
              </table></td>
            </tr>
		
            <tr>
              <td colspan="9">&nbsp;</td>
            </tr>
            <tr>
              <td><div align="center">
                  <input name="Submit1" type="button" class="form" id="Submit1" value="FECHAR" onClick="window.close()">
              </div></td>
              <td colspan="8">
                
                <div align="right">
                    <button type="submit" class="botao" name="confirma" disabled="disabled" onClick="document.form1.sacao.value = 'inc'">Confirmar Solicitação de Permuta</button>
                </div></td>
			</tr>			

            <input name="frmmotivo" type="hidden" id="frmmotivo" value="">
            <input name="sacao" type="hidden" id="sacao" value="">
            <input name="frmse" type="hidden" id="frmse" value="<cfoutput>#form.frmse#</cfoutput>">
            <input name="frmano" type="hidden" id="frmano" value="<cfoutput>#form.frmano#</cfoutput>">
            <input name="frmunidde" type="hidden" id="frmunidde" value="<cfoutput>#form.frmunidde#</cfoutput>">
			<input name="frmuniddedesc" type="hidden" id="frmuniddedesc" value="<cfoutput>#trim(rsUnidde.Und_Descricao)#</cfoutput>">
			<input name="frmunidpara" type="hidden" id="frmunidpara" value="<cfoutput>#form.frmunidpara#</cfoutput>">
			<input name="frmunidparadesc" type="hidden" id="frmunidparadesc" value="<cfoutput>#trim(rsUnidpara.Und_Descricao)#</cfoutput>">
			<input name="frmtipounid" type="hidden" id="frmtipounid" value="<cfoutput>#form.frmtipounid#</cfoutput>">
          </form>

          <!--- FIM DA ÁREA DE CONTEÚDO --->
        </table>
	
	    <!--- Término da área de conteúdo --->
</body>
</html>

