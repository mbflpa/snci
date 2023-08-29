<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif> 

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<cfinclude template="cabecalho.cfm">
<link href="CSS.css" rel="stylesheet" type="text/css">
<style type="text/css">
.style1 {font-size: 12px}
</style>

<cfquery name="qdr" datasource ="#dsn_inspecao#">
  SELECT Dir_Descricao, Dir_Codigo FROM Diretoria WHERE Dir_Status = 'A' 
</cfquery>

<cfquery name="qcategoria" datasource ="#dsn_inspecao#">
  SELECT Cat_Descricao, Cat_Codigo FROM CategoriaUnidades WHERE Cat_Status = 'A' 
</cfquery>

<cfquery name="qreop" datasource = "#dsn_inspecao#">
  SELECT Rep_Codigo, Rep_Nome FROM Reops WHERE Rep_Status = 'A' ORDER BY Rep_Nome
</cfquery>

<cfquery name="qtipo" datasource = "#dsn_inspecao#">
  SELECT TUN_Codigo, TUN_Descricao FROM Tipo_Unidades WHERE TUN_Status = 'A' ORDER BY TUN_Descricao
</cfquery>
</head>
<body>
<form name="frmUnidade" method="post" action="Adicionar_Unidade_acao.cfm">

<table width="90%" border="0" class="exibir"><br>
  <tr>
    <td colspan="10" class="titulo1">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="10" class="titulo1"><div align="center">Unidades</div></td>
    </tr>
  <tr>
    <td colspan="3">&nbsp;</td>
    <td colspan="7">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td colspan="8"><strong class="titulosClaro style1">Dados Unidades</strong></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="8">&nbsp;</td>
    </tr>
  <tr>
    <td width="7">&nbsp;</td>
    <td width="49"><div align="center" class="titulosClaro">*</div></td>
    <td width="158" class="titulos">C&oacute;digo da Unidade:</td>
    <td colspan="2"><input type="text" name="txtCodigo" size="10" maxlength="8" class="form"></td>
    <td width="8"><div align="center" class="titulosClaro">*</div></td>
    <td><div align="left"><span class="titulos">CGC:</span></div></td>
    <td><input type="text" name="txtCGC" size="14" maxlength="14" class="form"></td>
    <td width="196">&nbsp;</td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td> <div align="center"></div></td>
    <td class="titulos">Sigla:</td>
    <td colspan="7"><input type="text" name="txtSigla" size="10" maxlength="10" class="form"></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><div align="center" class="titulosClaro">*</div></td>
    <td class="titulos">Nome da Unidade:</td>
    <td colspan="7"><input type="text" name="txtDescricao" size="80" maxlength="30" class="form"></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><div align="center"></div></td>
    <td class="titulos">Gerente da Unidade: </td>
    <td colspan="7"><input type="text" name="txtgerente" size="80" maxlength="80" class="form"></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><div align="center" class="titulosClaro">*</div></td>
    <td class="titulos">Categoria:</td>
    <td colspan="7"><select name="txtcategoria" class="form">
                  <option selected="selected" value="">---</option>
                  <cfoutput query="qcategoria">
                    <option value="#Cat_Codigo#">#Cat_Descricao#</option>
                  </cfoutput>
                  </select></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><div align="center" class="titulosClaro">*</div></td>
    <td class="titulos">Tipo de Unidade:</td>
    <td colspan="7"><select name="txttipo" class="form">
                  <option selected="selected" value="">---</option>
                  <cfoutput query="qTipo">
                    <option value="#TUN_Codigo#">#TUN_Descricao#</option>
                  </cfoutput>
                  </select></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><div align="center"></div></td>
    <td class="titulos">Email da Unidade ou do Gerente : </td>
    <td colspan="7"><input type="text" name="txtEmailUnidade" size="60" maxlength="100" class="form"></td>
  </tr>
  <tr>
    <td colspan="10">&nbsp;</td>
    </tr>
  <tr>
    <td colspan="10">&nbsp;</td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td><div align="center"></div></td>
    <td colspan="8" class="titulosClaro style1">Localiza&ccedil;&atilde;o Unidade </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><div align="center"></div></td>
    <td colspan="8" class="titulosClaro style1">&nbsp;</td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td><div align="center" class="titulosClaro">*</div></td>
    <td class="titulos">Diretoria:</td>
    <td colspan="7"><select name="txtDR" class="form">
                  <option selected="selected" value="">---</option>
                  <cfoutput query="qDr">
                    <option value="#Dir_Codigo#">#Dir_Descricao#</option>
                  </cfoutput>
                </select></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><div align="center" class="titulosClaro">*</div></td>
    <td><strong>&Oacute;rg&atilde;o Subordinador : </strong></td>
    <td colspan="7"><select name="txtReop" class="form">
                  <option selected="selected" value="">---</option>
                  <cfoutput query="qReop">
                    <option value="#Rep_Codigo#">#Rep_Nome#</option>
                  </cfoutput>
                  </select></td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td><div align="center" class="titulosClaro">*</div></td>
    <td><span class="titulos">Endere&ccedil;o:</span></td>
    <td colspan="7"><input type="text" name="txtEndereco" size="80" maxlength="40" class="form"></td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td><div align="center" class="titulosClaro">*</div></td>
    <td><span class="titulos">Cidade:</span></td>
    <td colspan="2"><input type="text" name="txtCidade" size="80" maxlength="40" class="form"></td>
    <td><span class="titulosClaro">*</span></td>
    <td width="26"> <div align="right" class="titulosClaro"><span class="titulos">UF:</span></div></td>
    <td width="70">
        <div align="right">
          <input type="text" name="txtUF" size="6" maxlength="2" class="form">
        </div></td>
    <td colspan="2"><div align="right"></div></td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td><div align="center" class="titulosClaro">*</div></td>
    <td><span class="titulos">Situa&ccedil;&atilde;o:</span></td>
    <td colspan="2">&nbsp;</td>
    <td colspan="5">&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td width="223"><input name="situacao" type="radio" value="A" checked class="form">
      <span class="titulos">Ativado</span></td>
    <td width="115"><input name="situacao" type="radio" value="D" class="form">
      <span class="titulos">Desativado</span></td>
    <td colspan="5">&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><div align="center" class="titulosClaro">( * )</div></td>
    <td colspan="8" class="titulosClaro style1">Campos obrigat&oacute;rios</td>
    </tr>
  <tr>
    <td colspan="3">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
    <td colspan="5">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="3">&nbsp;</td>
    <td colspan="2">
      <div align="left">
        <input name="cancelar" class="botao" type="button" value="Voltar" onClick="history.back()">
        <input type="submit" name="Adicionar" value="Adicionar" class="botao">
      </div></td>
    <td colspan="5">&nbsp;</td>
  </tr>
</table>
</form>
</body>
</html>
