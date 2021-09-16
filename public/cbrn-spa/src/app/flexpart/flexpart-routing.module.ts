import { MetDataComponent } from './met-data/met-data.component';
import { FlexpartPlotComponent } from './flexpart-plot/flexpart-plot.component';
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { FlexpartRunPreloadedComponent } from './flexpart-run-preloaded/flexpart-run-preloaded.component';
import { ChooseOutputComponent } from './flexpart-plot/choose-output/choose-output.component';
import { ResultResolverService } from './result-resolver.service';
import { FlexpartPlotFormComponent } from './flexpart-plot/flexpart-plot-form/flexpart-plot-form.component';
import { OutputFormComponent } from './flexpart-plot/output-form/output-form.component';



const routes: Routes = [
    {
        path: 'metdata',
        component: MetDataComponent,
    },
    {
        path: 'run',
        component: FlexpartRunPreloadedComponent,
    },
    {
        path: 'results',
        component: FlexpartPlotComponent,
        children: [
            {
                path: ':fpResultId',
                component: ChooseOutputComponent,
                resolve: {
                    fpResult: ResultResolverService,
                },
                children: [
                    {
                        path: ':fpOutputId',
                        component: OutputFormComponent,
                    },
                ]
            }
        ]
    },
    // {
    //     path: ':slug',
    //     component: EditorComponent,
    //     canActivate: [AuthGuard],
    //     resolve: {
    //         article: EditableArticleResolver
    //     }
    // }
];

@NgModule({
    imports: [RouterModule.forChild(routes)],
    exports: [RouterModule]
})


export class FlexpartRoutingModule { }