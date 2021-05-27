import { AroundPipe } from 'src/app/pipes/around.pipe';
import { FormComponent } from 'src/app/components/form/form.component';
import { CbrnMap } from './../../../../models/cbrn-map';
import { NotificationService } from './../../../../services/notification.service';
import { WebsocketService } from './../../../../services/websocket.service';
import { FormService } from './../../../../services/form.service';
import { MapService } from './../../../../services/map.service';
import { Subscription } from 'rxjs';
import { Form } from './../../../../models/form';
import { Component, OnInit, OnDestroy, ViewChild, AfterViewInit } from '@angular/core';
import { Validators, FormGroup } from '@angular/forms';
import { AbstractWsComponent } from 'src/app/abstract-classes/abstract-ws-component';
import { ApiRequestsService } from 'src/app/services/api-requests.service';

@Component({
    selector: 'app-met-data',
    templateUrl: './met-data.component.html',
    styleUrls: ['./met-data.component.scss']
})
export class MetDataComponent extends AbstractWsComponent implements OnInit, OnDestroy, AfterViewInit {

    formItems: any[] = [
        {
            controlName: 'startDay',
            label: 'Starting day',
            type: 'datepicker',
            validators: [Validators.required],
            minMaxDate: {max: new Date()}
        },
        {
            controlName: 'startTime',
            label: 'Starting time',
            type: 'select',
            value: {
                obj: ["00:00:00", "12:00:00"], 
                display: ["00:00:00", "12:00:00"]
            },
            validators: [Validators.required],
        },
        {
            controlName: 'endDay',
            label: 'End day',
            type: 'datepicker',
            validators: [Validators.required],
            minMaxDate: {max: new Date()}
        },
        {
            controlName: 'endTime',
            label: 'End time',
            type: 'select',
            value: {
                obj: ["00:00:00", "12:00:00"], 
                display: ["00:00:00", "12:00:00"]
            },
            validators: [Validators.required],
        },
        {
            controlName: 'timeStep',
            label: 'Time step [h]',
            type: 'select',
            value: {
                obj: [1, 3, 6],
                display: [1, 3, 6],
            },
            validators: [Validators.required],
        },
        {
            controlName: 'gridRes',
            label: 'Grid res. [°]',
            type: 'select',
            value: {
                obj: [0.1, 0.2, 0.5, 1., 2.], 
                display: [0.1, 0.2, 0.5, 1., 2.]
            },
            validators: [Validators.required],
        },
        {
            controlName: 'areaToRetrieve',
            label: 'Area to retrieve',
            type: 'input',
            value: {
                obj: [], 
                display: [], 
                withPipe: { pipe: AroundPipe }
            },
            validators: [Validators.required],
        },
    ];

    @ViewChild('appForm') appForm: FormComponent;
    
    mapSubscription: Subscription;

    constructor(
        private mapService: MapService,
        private requestService: ApiRequestsService,
        public formService: FormService,
        public websocketService: WebsocketService,
        public notificationService: NotificationService
    ) { 
        super(websocketService, notificationService);
    }

    ngAfterViewInit() {
        this.appForm.formGroup.get('areaToRetrieve')?.disable();

        this.mapSubscription = this.mapService.mapSubject.subscribe({
            next: (cbrnMap: CbrnMap) => {
                let area = cbrnMap.layerToArea(cbrnMap.areaSelection);
                this.appForm.form.newVal('areaToRetrieve', area);
            }
        });
    }

    ngOnInit(): void {
        super.ngOnInit();


        this.mapService.cbrnMap.addDrawControl();
        this.mapService.onAreaSelectionInit();
    }

    onSubmit() {
        const notifTitle = this.notificationService.addNotif('Met data retrieval', 'metDataRequest');

        let formFields = this.formService.formToObject();
        
        formFields.startDate = this.formService.removeTimeZone(this.formService.toDate(formFields.startDay, formFields.startTime));
        formFields.endDate = this.formService.removeTimeZone(this.formService.toDate(formFields.endDay, formFields.endTime));

        formFields = {
            ...formFields,
            ws_info: {channel: this.websocketService.channel, backid: notifTitle},
        }
        console.log(formFields);
        const payload = {
            ...formFields,
            request: "metdata_retrieval"
        }
        this.requestService.flexpartRequest(payload).subscribe({
            next: () => {
                alert("Meteorological data has been retrieved");
                this.notificationService.changeStatus(notifTitle, 'succeeded');
            },
            error: (error) => {
                alert(error.info);
                this.notificationService.changeStatus(notifTitle, 'failed');
            }
        })
    }

    ngOnDestroy() {
        super.ngOnDestroy();
        this.mapService.cbrnMap.removeDrawControl();
        this.mapService.cbrnMap.removeLayer(this.mapService.cbrnMap.areaSelection);
        this.mapSubscription.unsubscribe();
    }

}
