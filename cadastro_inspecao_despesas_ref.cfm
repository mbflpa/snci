<cfprocessingdirective pageEncoding ="utf-8">
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
  SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena, Dir_Descricao, Usu_Matricula
  FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
  WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
  order by Dir_Sigla
</cfquery>
<cfset grpacesso = ucase(trim(qAcesso.Usu_GrupoAcesso))>

<cfquery name="qSE" datasource="#dsn_inspecao#">
  SELECT Dir_Codigo, Dir_Sigla 
  FROM Diretoria
  where dir_codigo <> '01' 
  <cfif grpacesso eq 'GESTORES'>
    and Dir_Codigo in(#qAcesso.Usu_Coordena#)
  </cfif>
  Order by Dir_Sigla
</cfquery>

<cfquery name="rsAnoPacin" datasource="#dsn_inspecao#">    
  SELECT Right([INP_NumInspecao],4) AS inpano
  FROM Inspecao
  GROUP BY Right([INP_NumInspecao],4)
  HAVING (((Right([INP_NumInspecao],4))>='2018'))
  ORDER BY Right([INP_NumInspecao],4) DESC
</cfquery>   

<!--- =========================== --->

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="public/bootstrap/bootstrap.min.css">  
 <link href="css.css" rel="stylesheet" type="text/css">
 <style>
 .table {
  width: 100%;
  border-collapse: collapse;
  }
  td {
    font-size: 12px;
  }

  th {
    font-size: 12px;
  }
  h5 {
	font-weight: bold;
	font-size: 90%;
  }
.btnalterar{
	margin-top: 0.3em;
	padding: 0.2em;
	color: #180606;
	display: inline-block;
	width:85px;
	height:15px;
	background-color:#df680ce0;
	border-radius: 10px 20px;
	cursor: pointer;
	}	
.btnimprimir{
	margin-top: 0.3em;
	padding: 0.2em;
	color: #180606;
	display: inline-block;
	width:85px;
	height:15px;
	background-color:#10df0cf0;
	border-radius: 10px 20px;
	cursor: pointer;
	}	
  .todas {
    padding: 0.5em;
    width:400px;
    height:20px;
    font-size: 100%;
  }
</style>
</head>
<br>
<body>

<!--- <cfinclude template="cabecalho.cfm"> --->


<!--- area de conteudo   --->
<table width="50%" align="left">
  <tr>
    <td>

    <table class="table table-bordered" width="100%">
	<form action="cadastro_inspecao_despesas_ref.cfm" method="post" target="_blank" name="frmObjeto" onSubmit="return validarform()">

        <tbody>
          <tr>
            <td colspan="5" align="center" class="titulo2"><div class="row"><strong>Cadastro Despesas Avaliação</strong></div></td>
          </tr>
          <tr>
            <th scope="row">Exercício</th>
            <td align="left" colspan="1">
              <select name="frmano" id="frmano" class="form-select">
                  <cfloop query="rsAnoPacin">                                             
                      <option value="<cfoutput>#rsAnoPacin.inpano#</cfoutput>"><cfoutput>#rsAnoPacin.inpano#</cfoutput></option>
                  </cfloop>
              </select>
          </td>
          </tr>
          <tr>
            <th scope="row" colspan="2">Período</th>
          </tr>
          <tr>
            <th scope="row">Início</th>
            <td  colspan="1">
              <input class="form-control" id="dtinic" name="dtinic" type="date" placeholder="DD/MM/AAAA">
            </td>
          </tr>
          <tr>
            <th scope="row">Final</th>
            <td colspan="1"><input class="form-control" id="dtfinal" name="dtfinal" type="date" placeholder="DD/MM/AAAA"></td>
          </tr>
          <tr>
            <th scope="row">Superintendência</th>
            <td colspan="1">
              <select name="frmse" id="frmse" class="form-select">
                <option value="" selected>---</option>
                <option value="t">Todas</option>
                <cfoutput query="qSE">
                      <option value="#qSE.Dir_Codigo#">#Ucase(trim(qSE.Dir_Sigla))#</option>
                </cfoutput>
              </select>    
            </td>

          </tr>
          <tr>
            <th scope="row">Avaliações</th>
            <td colspan="1">
              <select name="frmavaliacao" id="frmavaliacao" class="form-select">                                          
                <option value="">---</option>
              </select>
            </td>
          </tr>
        </tbody>
      </table>
	</form>          
      </table>
    </td>
  </tr>
  <tr>
    <td>
      <!---  style="display:none;" --->
	    <div id='table'>
      </div>
    </td>
  </tr>
</table>        


</body>
<script src="public/jquery-3.7.1.min.js"></script>
<script type="text/javascript" src="public/axios.min.js"></script>
<script>
      //buscar o avaliações
      $('#frmse').change(function(e){ 
        let prots = '<option value="" selected>---</option>';
        prots += '<option value="t">Todas</option>'
        if($(this).val() != ''){   
            let ano = $('#frmano').val() 
            let dtinic = $('#dtinic').val() 
            dtinic += ' 23:59:59.000'
            let dtfinal = $('#dtfinal').val()
            dtfinal += ' 23:59:59.999'
            let frmse = $(this).val()
            axios.get("CFC/revisaoanalise.cfc",{
                params: {
                    method: "despesasavaliacao",
                    ano: ano,
                    dtinic: dtinic,
                    dtfinal: dtfinal,
                    codse: frmse
                }
            })
            .then(data =>{
            var vlr_ini = data.data.indexOf("COLUMNS");
            var vlr_fin = data.data.length
            vlr_ini = (vlr_ini - 2);
            const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
            const dados = json.DATA;
            //INP_NumInspecao, Und_Descricao
            dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[0]+'-'+ret[1] + '</option>';
            });
            if (dados.length < 1) {prots = '<option value="" selected>---</option>';}
            $("#frmavaliacao").html(prots);
            })  
        }
      })//fim buscar avaliações  
 
      //preencher tabela
      $('#frmavaliacao').change(function(e){ 
        $("#table").hide(500) 
        if($(this).val() != ''){   
            let ano = $('#frmano').val(); 
            let dtinic = $('#dtinic').val() 
            dtinic += ' 23:59:59.000'
            let dtfinal = $('#dtfinal').val()
            dtfinal += ' 23:59:59.999'
            let frmse = $('#frmse').val(); 
            let aval = $(this).val()

            //alert(ano + ' ' + frmse + ' ' + matr)
            axios.get("CFC/revisaoanalise.cfc",{
                params: {
                    method: "mostraravaliacao",
                    ano: ano,
                    dtinic: dtinic,
                    dtfinal: dtfinal,
                    codse: frmse,
                    aval: aval
                }
            })
            .then(data =>{
              let totreal = 0
              let colprevisto = 0
              let coladinot = 0
              let coldesloc = 0
              let coldiarias = 0
              let colpassarea = 0
              let colreveicprop = 0
              let colrepourem = 0
              let colresemp = 0
              let coloutros = 0
              let colreal = 0
              let tab = '<table class="table table-bordered table-hover border-primary">'
              tab += '<thead>'
              tab += '<tr>'
              tab +=  '<th scope="col">Alterar</th>'
              tab +=  '<th scope="col">Avaliação</th>'
              tab +=  '<th scope="col">Nome da Unidade</th>'
              tab +=  '<th scope="col">Despesas(Lançam.)</th>'
              tab +=  '<th scope="col">Despesas(Gestor(a))</th>'
              tab +=  '<th scope="col">Previsto</th>'
              tab +=  '<th scope="col">Noturno</th>'
              tab +=  '<th scope="col">Desloc.</th>'
              tab +=  '<th scope="col">Diárias</th>'
              tab +=  '<th scope="col">Pass.Aérea</th>'
              tab +=  '<th scope="col">Reemb.Veic.Próprio</th>'
              tab +=  '<th scope="col">Repou.Remun</th>'
              tab +=  '<th scope="col">Ressarc.Empreg</th>'
              tab +=  '<th scope="col">Outros</th>'
              tab +=  '<th scope="col">Realizado</th>'
              tab += '</tr>'
              tab += '</thead>'
              tab += '<tbody>'
              var vlr_ini = data.data.indexOf("COLUMNS");
              var vlr_fin = data.data.length
              vlr_ini = (vlr_ini - 2);
              const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
              const dados = json.DATA;
              // INP_NumInspecao, Und_Descricao, format(INP_DTConcluir_Despesas,'dd-MM-yyyy HH:mm:ss') as inpdtconcluirdespesas, Usu_Apelido, INP_ValorPrevisto, INP_AdiNoturno
              //       0               1                                                                           2                   3                4                5     
              //, INP_Deslocamento, INP_Diarias, INP_PassagemArea, INP_ReembVeicProprio, INP_RepousoRemunerado, INP_RessarcirEmpregado, INP_Outros 
              //         6              7               8                    9                     10                       11              12
              dados.map((ret) => {
                totreal = ret[5]+ret[6]+ret[7]+ret[8]+ret[9]+ret[10]+ret[11]+ret[12]
                colprevisto = colprevisto+ret[4]
                coladinot = coladinot+ret[5]
                coldesloc = coldesloc+ret[6]
                coldiarias = coldiarias+ret[7]
                colpassarea = colpassarea+ret[8]
                colreveicprop = colreveicprop+ret[9]
                colrepourem = colrepourem+ret[10]
                colresemp = colresemp+ret[11]
                coloutros = coloutros+ret[12]
                colreal = colreal + totreal
               /* */
                let url = 'href=cadastro_inspecao_despesas_relat.cfm?numaval='+ret[0]+'&ano='+ano+'&codse='+frmse+'&dtinic='+$('#dtinic').val()+'&dtfinal='+$('#dtfinal').val()
                let urlalt = 'href=cadastro_inspecao_despesas.cfm?numInspecao='+ret[0]    
                //alert(url)
                tab += '<tr>'
                  tab += '<td class="alert alert-primary"><a class="alert-link" '+urlalt+' target="_blank"><div class="btnalterar" align="center" title="Alterar esta"><h5>Alterar este</h5></div></a></td>'
                  tab += '<td class="alert alert-primary"><a class="alert-link" '+url+' target="_blank"><div class="btnimprimir" align="center" title="Imprimir esta"><h5>'+ret[0]+'</h5></div></a></td>'
                  //tab += '<td class="alert alert-primary"><a class="alert-link" '+url+' target="_blank">'+ret[0]+'</a></td>'
                  tab += '<td>'+ret[1]+'</td>'
                  tab += '<td>'+ret[2]+'</td>'
                  tab += '<td>'+ret[3]+'</td>'
                  tab += '<td>'+ret[4].toLocaleString('pt-br', {minimumFractionDigits: 2})+'</td>'
                  tab += '<td>'+ret[5].toLocaleString('pt-br', {minimumFractionDigits: 2})+'</td>'
                  tab += '<td>'+ret[6].toLocaleString('pt-br', {minimumFractionDigits: 2})+'</td>'
                  tab += '<td>'+ret[7].toLocaleString('pt-br', {minimumFractionDigits: 2})+'</td>'
                  tab += '<td>'+ret[8].toLocaleString('pt-br', {minimumFractionDigits: 2})+'</td>'
                  tab += '<td>'+ret[9].toLocaleString('pt-br', {minimumFractionDigits: 2})+'</td>'
                  tab += '<td>'+ret[10].toLocaleString('pt-br', {minimumFractionDigits: 2})+'</td>'
                  tab += '<td>'+ret[11].toLocaleString('pt-br', {minimumFractionDigits: 2})+'</td>'
                  tab += '<td>'+ret[12].toLocaleString('pt-br', {minimumFractionDigits: 2})+'</td>'
                  tab += '<td>'+totreal.toLocaleString('pt-br', {minimumFractionDigits: 2})+'</td>'
                tab += '</tr>'
              }); 
              let urltodos = 'href=cadastro_inspecao_despesas_relat.cfm?numaval=t&ano='+ano+'&codse=t&dtinic='+$('#dtinic').val()+'&dtfinal='+$('#dtfinal').val()           
              tab += '<tr>'
                  tab += '<td colspan="5" align="right"><strong>Totais</strong></td>'
                  tab += '<td>'+colprevisto.toLocaleString('pt-br', {minimumFractionDigits: 2})+'</td>'
                  tab += '<td>'+coladinot.toLocaleString('pt-br', {minimumFractionDigits: 2})+'</td>'
                  tab += '<td>'+coldesloc.toLocaleString('pt-br', {minimumFractionDigits: 2})+'</td>'
                  tab += '<td>'+coldiarias.toLocaleString('pt-br', {minimumFractionDigits: 2})+'</td>'
                  tab += '<td>'+colpassarea.toLocaleString('pt-br', {minimumFractionDigits: 2})+'</td>'
                  tab += '<td>'+colreveicprop.toLocaleString('pt-br', {minimumFractionDigits: 2})+'</td>'
                  tab += '<td>'+colrepourem.toLocaleString('pt-br', {minimumFractionDigits: 2})+'</td>'
                  tab += '<td>'+colresemp.toLocaleString('pt-br', {minimumFractionDigits: 2})+'</td>'
                  tab += '<td>'+coloutros.toLocaleString('pt-br', {minimumFractionDigits: 2})+'</td>'
                  tab += '<td>'+colreal.toLocaleString('pt-br', {minimumFractionDigits: 2})+'</td>'
              tab += '</tr>'
              tab += '<tr>'
              tab += '<td colspan="15" class="alert alert-primary"><a class="alert-link" '+urltodos+' target="_blank"><div class="btnimprimir todas" align="center" title="Imprimir esta"><h5><strong>Clique aqui para imprimir todas (Superintendência e Avaliações)</strong></h5></div></a></td>'
              tab += '</tr>'
              tab += '</tbody>'
              tab += '</table>'              
              $("#table").html(tab);
              $("#table").show(500)
            })  
        }
      })//fim preencher tabela               
      //Limpar os selects bases   
      $('#frmano').change(function() {
        $("#frmse").val("").change();
        let prots = '<option value="" selected>---</option>';
        $("#frmrevisores").html(prots);
        $("#frmavaliacao").html(prots);
        $("#table").hide(500)
      }); 
      $('#frmse').change(function() {
        let prots = '<option value="" selected>---</option>';
        $("#frmrevisores").html(prots);
        $("#frmavaliacao").html(prots);
        $("#table").hide(500)
      }); 
      $('#frmrevisores').change(function() {
        let prots = '<option value="" selected>---</option>';
        $("#frmavaliacao").html(prots);
        $("#table").hide(500)
      });
      $('#dtinic').change(function() {
        $("#frmse").val("").change();
        let prots = '<option value="" selected>---</option>';
        $("#frmrevisores").html(prots);
        $("#frmavaliacao").html(prots);
        $("#table").hide(500)
      });
      $('#dtfinal').change(function() {
        $("#frmse").val("").change();
        let prots = '<option value="" selected>---</option>';
        $("#frmrevisores").html(prots);
        $("#frmavaliacao").html(prots);
        $("#table").hide(500)
      }); 
      //final Limpar os selects bases
      $(".external").attr("target","_blank")
</script>
</html>
