declare module 'img-diff-js' {
    export interface ImgDiffOpts {
        actualFilename: string;
        expectedFilename: string;
        diffFilename: string;
        threshold?: number;
        includeAA?: boolean;
    }
    export interface ImgDiffResult {
        imagesAreSame: boolean;
        width: number;
        height: number;
        diffCount: number;
    }
    export function imgDiff(opts?: ImgDiffOpts): ImgDiffResult;
}
