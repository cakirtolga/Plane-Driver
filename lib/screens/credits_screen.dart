import 'package:flutter/material.dart';
import 'package:planedriver_flame/l10n/app_localizations.dart';
import 'package:planedriver_flame/utils/theme.dart';
import 'package:planedriver_flame/widgets/plane_ui.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});
  @override Widget build(BuildContext context){final l=AppLocalizations.of(context);return Scaffold(body:PlaneScreenBackground(child:SafeArea(child:Stack(children:[Positioned(left:16,top:16,child:PlaneIconButton(icon:Icons.arrow_back_rounded,onPressed:()=>Navigator.pop(context))),Center(child:PlaneDialogSurface(maxWidth:520,child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.flight_rounded,color:PlaneDriverTheme.yellow,size:64),const SizedBox(height:10),Text(l.appTitle.toUpperCase(),style:Theme.of(context).textTheme.headlineMedium),const SizedBox(height:8),Text(l.creditsText,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white70,fontWeight:FontWeight.w700,height:1.4)),const SizedBox(height:18),PlanePrimaryButton(label:l.back,icon:Icons.arrow_back_rounded,onPressed:()=>Navigator.pop(context))])))]))));}
}
