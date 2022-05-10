import { Observable, of, Subject } from 'rxjs';
import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { Select, Store } from '@ngxs/store';
import { FlexpartOutputAction } from 'src/app/core/state/actions/flexpart-output.actions';
import { FlexpartOutput } from '../../flexpart-output';
import { FlexpartOutputState } from 'src/app/core/state/flexpart-output.state';
import { map } from 'rxjs/operators';

@Component({
    selector: 'app-variable-selection',
    templateUrl: './variable-selection.component.html',
    styleUrls: ['./variable-selection.component.scss']
})
export class VariableSelectionComponent implements OnInit {

    @Select(FlexpartOutputState.getFlexpartOutput)
    fpOutput$: Observable<FlexpartOutput>;
    
    fpOutputVar2D$: Observable<string[]>;

    selectedVarSub = new Subject<string>();
    selectedVar$: Observable<string>;

    constructor(
        private route: ActivatedRoute,
        private store: Store,
    ) {
        this.selectedVar$ = this.selectedVarSub.asObservable();
    }
    
    ngOnInit(): void {
        this.route.data.subscribe(data => {
            this.store.dispatch(new FlexpartOutputAction.Add(data.fpOutput));
        })

        this.fpOutputVar2D$ = this.fpOutput$.pipe(map(out => out.variables2d))
    }

    goToVariable(i: number) {
        this.selectedVarSub.next((this.store.selectSnapshot(state => state.fpOutput.fpOutput.variables2d[i])));
    }

}