/* eslint-disable @typescript-eslint/naming-convention */

export interface Country {
    name: string;
    dialCode: string;
    countryCode: string;
}

export interface Paths {
    logo?: string;
}

export interface RequestDescriptor {
    OrderBy: string;
    OrderType?: SortOrderType;
    pageNumber: number;
    pageSize: number;
}

export interface Usage {
    cpu?: string;
    memory?: string;
}

export type SortOrderType = 'asc' | 'desc' | '';

export type PlatformNL = 'MoT' | 'Enforcer';
