<cfprocessingdirective pageEncoding ="utf-8">

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
  SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena, Dir_Descricao, Usu_Matricula,Usu_AtivFacin
  FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
  WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
  order by Dir_Sigla
</cfquery>

<cfquery name="rsAnoPacin" datasource="#dsn_inspecao#">    
    SELECT PTC_Ano 
    FROM Pontuacao 
    GROUP BY PTC_Ano 
    HAVING (PTC_Ano) >= 2018
    order by PTC_Ano desc
</cfquery>   

<cfset auxanoatu = year(now())>
<cfquery name="rsAno" datasource="#dsn_inspecao#">
  SELECT Andt_AnoExerc
  FROM Andamento_Temp
  GROUP BY Andt_AnoExerc
  HAVING Andt_AnoExerc  < '#auxanoatu#'
  ORDER BY Andt_AnoExerc DESC
</cfquery>
<cfset auxse = ''>
<cfset AtivFacin = ucase(trim(qAcesso.Usu_AtivFacin))>
<cfloop list="#AtivFacin#" index="i">
  <cfset auxcol = "#i#">
  <cfset auxse = auxcol>
</cfloop>  
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
	<form action="ficha_facin_gestao_ref.cfm" method="post" target="_blank" name="frmObjeto" onSubmit="return validarform()">

        <tbody>
          <tr>
            <td colspan="5" align="center" class="titulo2"><div class="row"><strong>Relatório análise de Revisão</strong></div></td>
          </tr>
          <tr>
            <th scope="row">Exercício</th>
            <td align="left" colspan="1">
              <select name="frmano" id="frmano" class="form-select">
                  <cfloop query="rsAnoPacin">                                             
                      <option value="<cfoutput>#rsAnoPacin.PTC_Ano#</cfoutput>"><cfoutput>#rsAnoPacin.PTC_Ano#</cfoutput></option>
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
            <cfif auxse eq 'D'>	
              <select name="frmse" id="frmse" class="form-select">
                    <option value="" selected>---</option>
                    <option value="<cfoutput>#qAcesso.Usu_DR#</cfoutput>"><cfoutput>#qAcesso.Dir_Sigla#</cfoutput></option>
              </select>	
            <cfelse>
              <cfset auxcord = trim(qAcesso.Usu_Coordena)>
              <cfquery name="rsSE" datasource="#dsn_inspecao#">
                SELECT Dir_Codigo, Dir_Sigla FROM Diretoria where dir_codigo in(#auxcord#)
              </cfquery>
              <select name="frmse" id="frmse" class="form-select">
                <option value="" selected>---</option>
                <cfoutput query="rsSE">
                      <option value="#rsSE.Dir_Codigo#">#Ucase(trim(rsSE.Dir_Sigla))#</option>
                </cfoutput>
              </select>    
            </cfif>	
            </td>

          </tr>
          <tr>
            <th scope="row">Revisores</th>
            <td colspan="1">
              <select name="frmrevisores" id="frmrevisores" class="form-select">                                          
                <option value="">---</option>
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

<!--- 	  <input name="grupoacesso" type="hidden" value="<cfoutput>#qAcesso.Usu_GrupoAcesso#</cfoutput>">
	  <input name="usucoordena" type="hidden" value="<cfoutput>#qAcesso.Usu_Coordena#</cfoutput>"> --->
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
      //buscar revisores
      $('#frmse').change(function(e){ 
        let prots = '<option value="" selected>---</option>';
        let dtinic = $('#dtinic').val() 
        dtinic += ' 23:59:59.000'
        let dtfinal = $('#dtfinal').val()
        dtfinal += ' 23:59:59.000'
        if(dtinic == '' || dtfinal == ''){
          alert('Selecionar o período (Início/Final) da FACIN')
          $('#dtinic').focus()
          return false
         }
        if($(this).val() != ''){     
            let ano = $('#frmano').val(); 
            let frmse = $(this).val(); 
            axios.get("CFC/revisaoanalise.cfc",{
                params: {
                    method: "revisores",
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
            dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
            });
            $("#frmrevisores").html(prots);
            })  
        }
      })//fim buscar inspetores 
      //buscar o avaliações
      $('#frmrevisores').change(function(e){ 
        let prots = '<option value="" selected>---</option>';
        if($(this).val() != ''){    
            let dtinic = $('#dtinic').val() 
            dtinic += ' 23:59:59.000'
            let dtfinal = $('#dtfinal').val()
            dtfinal += ' 23:59:59.999'
            let ano = $('#frmano').val(); 
            let frmse = $('#frmse').val(); 
            let matr = $(this).val(); 
            //alert(ano + ' ' + frmse + ' ' + matr)
            axios.get("CFC/revisaoanalise.cfc",{
                params: {
                    method: "avaliacao",
                    ano: ano,
                    codse: frmse,
                    dtinic: dtinic,
                    dtfinal: dtfinal,
                    matr: matr
                }
            })
            .then(data =>{
            
            var vlr_ini = data.data.indexOf("COLUMNS");
            var vlr_fin = data.data.length
            vlr_ini = (vlr_ini - 2);
            const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
            const dados = json.DATA;
            if (dados != ''){prots += '<option value="t">Todas</option>'}
            //INP_NumInspecao,Und_Descricao,INP_DTConcluirRevisao,Usu_Matricula,Dir_Sigla
            dados.map((ret) => {
                prots += '<option value="'+ret[0]+'">'+'SE/'+ret[4]+' - '+ret[0]+' - '+ret[1]+'</option>';
            });
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
            let matrevisor = $('#frmrevisores').val(); 
            let aval = $(this).val()
            //alert(ano + ' ' + frmse + ' ' + matr)
            axios.get("CFC/revisaoanalise.cfc",{
                params: {
                    method: "gestao",
                    ano: ano,
                    dtinic: dtinic,
                    dtfinal: dtfinal,
                    codse: frmse,
                    matrevisor: matrevisor,
                    aval: aval 
                }
            })
            .then(data =>{
              let tab = '<table class="table table-bordered table-hover border-primary">'
              tab += '<thead>'
              tab += '<tr>'
              tab +=  '<th scope="col">Clique no Nº Avaliação</th>'
              tab +=  '<th scope="col">Tipo</th>'
              tab +=  '<th scope="col">Conclusão Avaliação</th>'
              tab +=  '<th scope="col">Início Revisão</th>'
              tab +=  '<th scope="col">Últ. Tratativa Fase Avaliação</th>'
              tab +=  '<th scope="col">Conclusão Revisão</th>'
              tab += '</tr>'
              tab += '</thead>'
              tab += '<tbody>'
              var vlr_ini = data.data.indexOf("COLUMNS");
              var vlr_fin = data.data.length
              vlr_ini = (vlr_ini - 2);
              const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
              const dados = json.DATA;
              //RIP_NumInspecao,TUN_Descricao,INP_DTConcluirAvaliacao,INP_RevisorDTInic,RIP_DtUltAtu,INP_DTConcluirRevisao
              //       0              1                    2                     3                4                 5      
              dados.map((ret) => {
                let url = 'href=Revisor_analise_relat.cfm?ninsp='+ret[0]+'&matrevisor='+matrevisor
                //alert(url)
                tab += '<tr>'
                 // tab += '<td class="alert alert-primary"><a class="alert-link" '+url+' target="_blank">'+ret[0]+'</a></td>'
                  tab += '<td class="alert alert-primary"><a class="alert-link" '+url+' target="_blank"><div class="btnimprimir" align="center" title="Imprimir esta"><h5>'+ret[0]+'</h5></div></a></td>'
                  tab += '<td>'+ret[1]+'</td>'
                  tab += '<td>'+ret[2]+'</td>'
                  tab += '<td>'+ret[3]+'</td>'
                  tab += '<td>'+ret[4]+'</td>'
                  tab += '<td>'+ret[5]+'</td>'
                tab += '</tr>'
              });
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
